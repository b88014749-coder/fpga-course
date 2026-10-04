#include "xparameters.h"
#include "xil_io.h"
#include "xaxidma.h"
#include "xgpio.h"

#define BTN_BASEADDR   XPAR_AXI_GPIO_0_BASEADDR
#define GPIO_CHANNEL_IN    1
#define GPIO_CHANNEL_OUT   2

#define DMA_BASEADDR XPAR_AXI_DMA_0_BASEADDR
#define RAM_BASE XPAR_AXI4_FULL_RAM_0_BASEADDR

#define DST_ADDR      (RAM_BASE)

//Here we assume that it is a display with 8 bit per pixel
#define LENGTH        (320 * 200)

static XAxiDma dma_inst;
static XGpio btn_gpio;

static int gpio_Init(void)
{
    XGpio_Initialize(&btn_gpio, BTN_BASEADDR);

    XGpio_SetDataDirection(&btn_gpio, GPIO_CHANNEL_IN, 0x1);
    XGpio_SetDataDirection(&btn_gpio, GPIO_CHANNEL_OUT, 0x0);

    XGpio_DiscreteWrite(&btn_gpio, GPIO_CHANNEL_OUT, 0);

    return XST_SUCCESS;
}

static int dma_Init(void)
{
    XAxiDma_Config *cfg = XAxiDma_LookupConfig(DMA_BASEADDR);
    if (cfg == NULL) {
        return XST_FAILURE;
    }

    return XAxiDma_CfgInitialize(&dma_inst, cfg);    
}

int main(void)
{
    if (gpio_Init() == XST_SUCCESS &&
            dma_Init() == XST_SUCCESS) {
        u32 prev_start_btn = XGpio_DiscreteRead(&btn_gpio, GPIO_CHANNEL_IN);

        while (1) {
            //To simplify the simulation do not debounce the button
            u32 start_btn = XGpio_DiscreteRead(&btn_gpio, GPIO_CHANNEL_IN);
            if (!prev_start_btn && start_btn) {
                XGpio_DiscreteWrite(&btn_gpio, GPIO_CHANNEL_OUT, 1);
                
                //Initiate the transfer
                XAxiDma_SimpleTransfer(&dma_inst, DST_ADDR, LENGTH, XAXIDMA_DEVICE_TO_DMA);
                while (XAxiDma_Busy(&dma_inst, XAXIDMA_DEVICE_TO_DMA));
                
                XGpio_DiscreteWrite(&btn_gpio, GPIO_CHANNEL_OUT, 0);
            }
            prev_start_btn = start_btn;
        }
    }

    return XST_FAILURE;
}