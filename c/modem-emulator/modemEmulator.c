#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>
#include <poll.h>
#include <sys/wait.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <linux/tty.h>
#include <getopt.h>

static bool do_exit = false;
pthread_mutex_t emulatorData_mtx = PTHREAD_MUTEX_INITIALIZER;
pthread_t modem_thread;
pthread_t ppp_thread;
static int verbosity = 0;

static const char *program_name;

typedef enum modem_state_e {
    MODEM_ATCOMMANDS,
    MODEM_PPPD,
} modem_state_t;

const char *modem_state_str[] = {
    "MODEM_ATCOMMANDS",
    "MODEM_PPPD",
};

static char modemDevice[32] = "/dev/gsmtty2";
static modem_state_t modem_state = MODEM_ATCOMMANDS;
static modem_state_t modem_next_state;

static void print_usage (FILE* stream, int exit_code)
{
    fprintf(stream, "Usage:  %s options \n", program_name);
    fprintf(stream,
            "-h --help      :  Shows this help\n"
            "-v --verbosity :  Increase verbosity\n"
            "-t --type      :  Modem type (TBD)\n"
            "-d --device    :  Modem device (default: /dev/gsmtty2)\n");
    exit(exit_code);
}

static int openModemDevice(const char *path)
{
    int fd;
    char buffer[256];
    while (!do_exit) {
        fd = open(path, O_RDWR | O_NONBLOCK);
        if (fd >= 0)
        {
            while (1) {
                int ret = read(fd, buffer, sizeof(buffer));
                if (ret < 0) {
                    if (errno == EAGAIN || errno == EWOULDBLOCK) {
                        break;
                    } else {
                        perror("Error reading PTY");
                        break;
                    }
                }
            }
            fprintf(stderr, "Reconnected to %s\n", path);
            return fd;
        }
        perror("open failed");
        sleep(1); // wait before retrying
    }
    if (verbosity > 0)
    {
        fprintf(stderr, "Opened modem device %s with fd %d\n", path, fd);
    }
    return -1;
}

static void* pppThread(void *arg)
{
    pid_t pid = fork();
    if (pid < 0)
    {
        perror("fork failed");
        return NULL;
    }
    else if (pid == 0)
    {
        // Child process
        execlp("pppd", "pppd",  "call", "serial-ppp", "nodetach", "debug", (char *)NULL);
        perror("execlp failed");
        exit(EXIT_FAILURE);
    }
    else
    {
        // Parent process
        if (verbosity > 0)
        {
            fprintf(stderr, "Launched pppd with PID %d\n", pid);
        }
        // wait for child process to exit
        int status;
        waitpid(pid, &status, 0);
        if (verbosity > 0)
        {
            // TODO: use macros to decode status
            fprintf(stderr, "pppd exited with status %d\n", status);
        }
        pthread_mutex_lock(&emulatorData_mtx);
        modem_next_state = MODEM_ATCOMMANDS;
        pthread_mutex_unlock(&emulatorData_mtx);
    }
    return NULL;
}

static int writeATResponse(int fd, const char *buf, size_t len)
{
    if (verbosity > 0)
    {
        fprintf(stderr,"Sending response: %s\n", buf);
    }
    ssize_t ret = write(fd, buf, len);
    if(ret < 0)
    {
        perror("failed to write AT response");
    }
    return ret;
}

static void buildATResponse(const char *atCmd, char *response, char *buf, size_t bufSize, bool atEcho)
{
    if (atEcho)
    {
        snprintf(buf, bufSize, "%s\r\r\n%s", atCmd, response);
    }
    else
    {
        snprintf(buf, bufSize, "%s", response);
    }
}

static int processAtCmd(int fd, char *atCmd, size_t cmdLen)
{
    char buf[256];
    static bool atEcho = true;

    if (verbosity > 0)
    {
        fprintf(stderr,"Received %ld bytes: %s\n", cmdLen, atCmd);
    }
    if(strncmp(atCmd, "AT", cmdLen) == 0)
    {
        buildATResponse(atCmd, "OK\r\n", buf, sizeof(buf), atEcho);
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "ATI", cmdLen) == 0)
    {
        buildATResponse(atCmd, "RDY\r\r\nAPP RDY\r\nQuectel\r\nBG95-M3\r\nRevision: BG95M3LAR02A03\r\n\r\nOK\r\n", buf, sizeof(buf), atEcho);
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "ATE0", cmdLen) == 0)
    {
        buildATResponse(atCmd, "OK\r\n", buf, sizeof(buf), atEcho);
        atEcho = false;
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "ATE1", cmdLen) == 0)
    {
        buildATResponse(atCmd, "OK\r\n", buf, sizeof(buf), atEcho);
        atEcho = true;
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "AT+CGDCONT=1,", (cmdLen < 13) ? cmdLen : 13) == 0)
    {
        if (verbosity > 0)
        {
            fprintf(stderr, "Setting APN to: %.*s\n", (int)(cmdLen - 13), &atCmd[13]);
        }
        buildATResponse(atCmd, "OK\r\n", buf, sizeof(buf), atEcho);
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "AT+QMBNCFG=\"autosel\"", cmdLen) == 0)
    {
        buildATResponse(atCmd, "+QMBNCFG: \"autosel\",1\r\nOK\r\n", buf, sizeof(buf), atEcho);
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "AT+QCFG=\"nwscanmode\"", cmdLen) == 0)
    {
        buildATResponse(atCmd, "+QCFG: \"nwscanmode\",0\r\nOK\r\n", buf, sizeof(buf), atEcho);
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "AT+CFUN=1,1", cmdLen) == 0)
    {
        buildATResponse(atCmd, "OK\r\nAPP RDY\r\n", buf, sizeof(buf), atEcho);
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "AT+QPOWD=1", cmdLen) == 0)
    {
        buildATResponse(atCmd, "OK\r\nPOWERED DOWN\r\n", buf, sizeof(buf), atEcho);
        writeATResponse(fd, buf, strlen(buf));
        // Next time the GO detects ignition the modem will be powered up and the GO will wait for "APP RDY" message.
        // We don't know when that will be. We could parse console messages but for now just wait 2 seconds and send "APP RDY" message
        // so it is waiting to be read by the GO when it powers up the modem
        sleep(2);
        return writeATResponse(fd, "APP RDY\r\n", 9);
    }
    else if(strncmp(atCmd, "AT+CSQ", cmdLen) == 0)
    {
        buildATResponse(atCmd, "+CSQ: 17,99\r\nOK\r\n", buf, sizeof(buf), atEcho);
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "AT+COPS?", cmdLen) == 0)
    {
        buildATResponse(atCmd, "+COPS: 0,2,\"21407\",7\r\nOK\r\n", buf, sizeof(buf), atEcho);
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "AT+CEREG?", cmdLen) == 0)
    {
        buildATResponse(atCmd, "+CEREG: 0,1\r\nOK\r\n", buf, sizeof(buf), atEcho);
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "ATD*99#", cmdLen) == 0)
    {
        if (verbosity > 0)
        {
            fprintf(stderr, "Switching to PPP mode\n");
        }
        snprintf(buf, sizeof(buf), "CONNECT\r\n");
        pthread_mutex_lock(&emulatorData_mtx);
        modem_next_state = MODEM_PPPD;
        pthread_mutex_unlock(&emulatorData_mtx);
        return writeATResponse(fd, buf, strlen(buf));
    }
    else if(strncmp(atCmd, "AT+", 3) == 0)
    {
        buildATResponse(atCmd, "OK\r\n", buf, sizeof(buf), atEcho);
        return writeATResponse(fd, buf, strlen(buf));
    }
    return 0;
}

static int readCommands(int fd, char *buf, size_t bufSize)
{
    int ret;
    static int bytesInBuf = 0;

    ret = read(fd, &buf[bytesInBuf], bufSize - bytesInBuf);
    if (ret < 0)
    {
        return ret;
    }
    else if(ret > 0)
    {
        if (verbosity > 1)
        {
            char *tmpBuf = (char *)malloc(bufSize - bytesInBuf + 1);
            memcpy(tmpBuf, &buf[bytesInBuf], ret);
            tmpBuf[ret] = '\0';
            for (int i = 0; i < ret; i++)
            {
                if (tmpBuf[i] == '\r')
                {
                    // substitute carriage return to see the whole commands in the screen
                    tmpBuf[i] = '#';
                }
            }
            fprintf(stderr, "Read %d bytes from modem: %s\n", ret, tmpBuf);
            free(tmpBuf);
        }
        bytesInBuf += ret;

        int offset = 0;
        for(int i = 0; i < bytesInBuf; i++)
        {
            if(buf[i] == '\r')
            {
                buf[i] = '\0';
                processAtCmd(fd, &buf[offset], i - offset);
                offset = i+1;
            }
        }
        // Move any leftover data to the start of the buffer
        if (offset > 0 && offset < bytesInBuf)
        {
            memmove(buf, &buf[offset], bytesInBuf-offset);
        }
        bytesInBuf -= offset;

        if(bytesInBuf == bufSize)
        {
            bytesInBuf = 0;
        }
    }
    return ret;
}

static void* modemThread(void *arg)
{
    int ret;
    char buf[512];
    struct pollfd pollFd;
    int fd;

    modem_next_state = modem_state;
    if (verbosity > 0)
    {
        fprintf(stderr,"Modem thread started\n");
    }
    
    fd = openModemDevice(modemDevice);
    while (!do_exit)
    {
        switch(modem_state)
        {
            case MODEM_ATCOMMANDS:
                pollFd.fd = fd;
                pollFd.events = POLLIN;
                ret = poll(&pollFd, 1, 1000);
                if(ret < 0)
                {
                    if (errno != EINTR)
                    {
                        perror("poll failed");
                        goto exit_thread;
                    }
                    continue;
                }
                else if(ret == 0)
                {
                    // Timeout
                    if (verbosity > 2)
                    {
                        fprintf(stderr,"poll timeout\n");
                    }
                    continue;
                }

                if (pollFd.revents & (POLLERR | POLLHUP | POLLNVAL)) {
                    if (verbosity > 0)
                    {
                        fprintf(stderr, "device closed, reconnecting...\n");
                    }
                    close(fd);
                    fd = openModemDevice(modemDevice);
                    pollFd.fd = fd;
                    continue;
                }

                if (pollFd.revents & POLLIN) {
                    ret = readCommands(fd, buf, sizeof(buf));
                    if(ret < 0)
                    {
                        if (errno != EAGAIN && errno != EINTR)
                        {
                            perror("failed to read AT command");
                            goto exit_thread;
                        }
                    }
                    else if(ret == 0)
                    {
                        // EOF
                        if (verbosity > 0)
                        {
                            fprintf(stderr, "device closed, reconnecting...\n");
                        }
                        close(fd);
                        fd = openModemDevice(modemDevice);
                        pollFd.fd = fd;
                    }
                }
                break;
            case MODEM_PPPD:
                // In PPP mode, just pass data through
                if (verbosity > 1)
                {
                    fprintf(stderr,"In PPP mode, sleeping\n");
                }
                usleep(1000000);
                break;
            default:
                break;
        }

        pthread_mutex_lock(&emulatorData_mtx);
        modem_state_t _state = modem_next_state;
        pthread_mutex_unlock(&emulatorData_mtx);
        if (modem_state != _state)
        {
            if (verbosity > 0)
            {
                fprintf(stderr,"Modem state change: %s -> %s\n", modem_state_str[modem_state], modem_state_str[_state]);
            }
            modem_state = _state;
            if (_state == MODEM_PPPD)
            {
                // Lauch pppd
                pthread_create(&ppp_thread, NULL, pppThread, NULL);
            }
            else if (_state == MODEM_ATCOMMANDS)
            {
                // Wait for pppd thread to exit
                ret = pthread_join(ppp_thread, NULL);
                if (verbosity > 0)
                {
                    fprintf(stderr, "PPP thread exited with code %d\n", ret);
                }
            }
        }
    }
    if (verbosity > 0)
    {
        fprintf(stderr,"Modem thread exiting\n");
    }
exit_thread:
    return NULL;
}

static void modemInit(void)
{
    pthread_create(&modem_thread, NULL, modemThread, NULL);
}

void cleanup_and_exit(int sig)
{
    if (verbosity > 0)
    {
        fprintf(stderr, "Caught signal %d, exiting...\n", sig);
    }
    do_exit = true;
}

int main(int argc, char **argv)
{
    struct sigaction sa;
    const char* const short_options = "hvt:d:";
    const struct option long_options[] = {
        { "help",       0, NULL, 'h' },
        { "verbosity",  0, NULL, 'v' },
        { "type",       1, NULL, 't' },
        { "device",     1, NULL, 'd' },
        { NULL,       0, NULL, 0   }
    };

    program_name = argv[0];

    sa.sa_handler = cleanup_and_exit;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    if(sigaction(SIGINT, &sa, NULL) < 0)
    {
        perror("sigaction");
        exit(EXIT_FAILURE);
    }

    if(sigaction(SIGTERM, &sa, NULL) < 0)
    {
        perror("sigaction");
        exit(EXIT_FAILURE);
    }

    int next_option;
    do{
        next_option = getopt_long(argc, argv, short_options, long_options, NULL);

        switch (next_option)
        {
            case 'h':
                print_usage(stderr, 0);
                break;
            case 'v':
                verbosity++;
                break;
            case 't':
                // modemType = atoi(optarg); // TODO: implement different modem types. Currently only Quectel BG95 is supported
                break;
            case 'd':
                snprintf(modemDevice, sizeof(modemDevice), "%s", optarg);
                break;
            case '?':
                print_usage(stderr, 1);
                break;
            case -1:
                break;
            default:
                print_usage(stderr, 1);
                break;
        }
    } while (next_option != -1);


    if (verbosity > 0)
    {
        fprintf(stderr, "Starting modem emulator\n");
        fprintf(stderr, "Verbosity level: %d\n", verbosity);
        fprintf(stderr, "Using modem device: %s\n", modemDevice);
    }

    modemInit();

    pthread_join(modem_thread, NULL);

    return 0;
}
