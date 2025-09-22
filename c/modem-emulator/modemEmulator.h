#ifndef __MODEM_EMULATOR_H__
#define __MODEM_EMULATOR_H__

#include <stdbool.h>
#include <time.h>

enum modemType_e {
    MODEM_TYPE_NONE = 0,
    MODEM_TYPE_QUECTEL,
    MODEM_TYPE_SEQUANS,
    MODEM_TYPE_WNC,
    MODEM_TYPE_MAX
};

#endif // __MODEM_EMULATOR_H__
