#include "xil_io.h"
#include "xparameters.h"
#include "xil_printf.h"

#define FREQ_METER_BASEADDR XPAR_FREQ_CNTR_0_BASEADDR
#define REG_WINDOW  0x00U
#define REG_CTRL    0x04U
#define REG_COUNT   0x08U
#define REG_STATUS  0x0CU

#define CLK_FREQ_HZ 100000000U
#define WINDOW_SIZE 1000U

int main(void)
{
    u32 base = FREQ_METER_BASEADDR;

    xil_printf("Frequency counter test\r\n");

    /* Configure the measurement window */
    Xil_Out32(base + REG_WINDOW, WINDOW_SIZE);

    /* Start measurement */
    Xil_Out32(base + REG_CTRL, 1U);

    /* Wait until measurement completes */
    while ((Xil_In32(base + REG_STATUS) & 1U) == 0U) {
        /* Poll STATUS */
    }

    /* Read the measured number of rising edges */
    u32 count = Xil_In32(base + REG_COUNT);
     /* Calculate the measured signal frequency */
    u32 frequency_hz = (count * CLK_FREQ_HZ) / WINDOW_SIZE;

    xil_printf("COUNT = %lu\r\n", (unsigned long)count);
    xil_printf("Measured frequency = %lu Hz\r\n", (unsigned long)frequency_hz);

    while (1) {
        /* Keep the application running */
    }

    return 0;
}