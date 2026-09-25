#include <stdio.h>
#include "xparameters.h"
#include "xil_printf.h"

#include "xgpio.h"
#include "xtmrctr.h"
#include "xscugic.h"
#include "xinterrupt_wrap.h"

#define BTN_BASEADDR   XPAR_AXI_GPIO_0_BASEADDR
#define LED_BASEADDR   XPAR_AXI_GPIO_1_BASEADDR
#define SW_BASEADDR    XPAR_AXI_GPIO_2_BASEADDR
#define GPIO_CHANNEL    1

#define FCLK_CLK0_HZ    (100 * 1000000)
#define TIMER_BASEADDR XPAR_AXI_TIMER_0_BASEADDR
#define TIMER_LED_CNTR	 0
#define TIMER_BTN_CNTR	 1

#define TIMER_LED_RESET_VALUE	 FCLK_CLK0_HZ  //Set initial LED interval to 1sec
#define TIMER_LED_STEP_VALUE    (TIMER_LED_RESET_VALUE / 20)
#define TIMER_LED_MAX_VALUE     TIMER_LED_RESET_VALUE
#define TIMER_LED_MIN_VALUE     TIMER_LED_STEP_VALUE     

#define TIMER_BTN_RESET_VALUE_MS 1
#define TIMER_BTN_RESET_VALUE(t)	 (FCLK_CLK0_HZ / 1000 * (t))  //The buttons debouncing frequency
#define TIMER_BTN_DEB_INTERVAL_MS   (20 / TIMER_BTN_RESET_VALUE_MS)

/*
    SW0   -   Direction
    BTN0  -   Speed Up
    BTN1  -   Speed Down
    BTN2  -   Stop
    BTN3  -   Start
*/
#define SWITCH_SW0  1
#define BIT(x)  (1 << (x))

#define LED(x)  BIT(x)

#define BTN_SPEED_UP    BIT(0)
#define BTN_SPEED_DOWN  BIT(1)
#define BTN_STOP        BIT(2)
#define BTN_START       BIT(3)
#define BTN_NUM         4

static XGpio led_gpio, btn_gpio, sw_gpio;

static u32 debounced_inputs(const u32 inputs, const u32 mask)
{
    static u32 prev_value = 0;
    static u32 debounced_value = 0;
    static u32 counter = 0;
    
    if ((inputs & mask) == prev_value) {
        if (counter >= TIMER_BTN_DEB_INTERVAL_MS) {
            debounced_value = inputs & mask;
        } else {
            ++counter;
        }
    } else {
        prev_value = inputs & mask;
        counter = 0;
    }

    return debounced_value;
}

static void TimerIRQHandler(void *CallBackRef, u8 TmrCtrNumber)
{
    static u32 led_mask = LED(0);
    static u32 led_timer_value = TIMER_LED_RESET_VALUE;
	XTmrCtr *InstancePtr = (XTmrCtr *)CallBackRef;

    if (TIMER_LED_CNTR == TmrCtrNumber) {
        u32 sw_value = XGpio_DiscreteRead(&sw_gpio, GPIO_CHANNEL);

        if (sw_value & SWITCH_SW0) {
            led_mask = led_mask & LED(0) ? LED(3) : led_mask >> 1;
        } else {
            led_mask = led_mask & LED(3) ? LED(0) : led_mask << 1;
        }
        XGpio_DiscreteWrite(&led_gpio, GPIO_CHANNEL, led_mask & 0xF);
    } else {
        static u32 prev_value = 0;
        u32 cur_value = 0;

        cur_value = debounced_inputs(XGpio_DiscreteRead(&btn_gpio, GPIO_CHANNEL), 0xf);
        for (u32 idx = 0; cur_value != prev_value && idx < BTN_NUM; ++idx) {
            if (!(prev_value & BIT(idx)) && (cur_value & BIT(idx))) {
                switch (BIT(idx)) {
                    case BTN_SPEED_UP:
                        if (InstancePtr->IsStartedTmrCtr0) {
                            if (led_timer_value > TIMER_LED_MIN_VALUE) {
                                led_timer_value -= TIMER_LED_STEP_VALUE;
                                XTmrCtr_SetResetValue(InstancePtr, TIMER_LED_CNTR, led_timer_value);
                            } else {
                                led_timer_value = TIMER_LED_MIN_VALUE;
                            }
                        }
                        break;
                    case BTN_SPEED_DOWN:
                        if (InstancePtr->IsStartedTmrCtr0) {
                            if (led_timer_value < TIMER_LED_MAX_VALUE) {
                                led_timer_value += TIMER_LED_STEP_VALUE;
                                XTmrCtr_SetResetValue(InstancePtr, TIMER_LED_CNTR, led_timer_value);
                            } else {
                                led_timer_value = TIMER_LED_MAX_VALUE;
                            }
                        }
                        break;
                    case BTN_STOP:
                        if (InstancePtr->IsStartedTmrCtr0) {
                            XTmrCtr_Stop(InstancePtr, TIMER_LED_CNTR);
                        }
                        break;
                    case BTN_START:
                        if (!InstancePtr->IsStartedTmrCtr0) {
                            XTmrCtr_Start(InstancePtr, TIMER_LED_CNTR);
                        }
                        break;
                    default:
                        break;
                }
            }
        }
        prev_value = cur_value;
    }
}

static int gpio_Init(void)
{
    XGpio_Initialize(&led_gpio, LED_BASEADDR);
    XGpio_Initialize(&btn_gpio, BTN_BASEADDR);
    XGpio_Initialize(&sw_gpio, SW_BASEADDR);

    XGpio_SetDataDirection(&led_gpio, GPIO_CHANNEL, 0x0);
    XGpio_SetDataDirection(&btn_gpio, GPIO_CHANNEL, 0xF);
    XGpio_SetDataDirection(&sw_gpio,  GPIO_CHANNEL, 0x3);

    return XST_SUCCESS;
}

static int timer_Init(XTmrCtr* timer)
{
    int Status;

    Status = XTmrCtr_Initialize(timer, TIMER_BASEADDR);
    if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

    Status = XSetupInterruptSystem(timer, (XInterruptHandler)XTmrCtr_InterruptHandler,
				       timer->Config.IntrId, timer->Config.IntrParent,
				       XINTERRUPT_DEFAULT_PRIORITY);
    if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

    XTmrCtr_SetHandler(timer, TimerIRQHandler, timer);

    XTmrCtr_SetOptions(timer, TIMER_LED_CNTR,
			   XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION);
    XTmrCtr_SetResetValue(timer, TIMER_LED_CNTR, TIMER_LED_RESET_VALUE);
    XTmrCtr_Start(timer, TIMER_LED_CNTR);

    XTmrCtr_SetOptions(timer, TIMER_BTN_CNTR,
			   XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION);
    XTmrCtr_SetResetValue(timer, TIMER_BTN_CNTR, TIMER_BTN_RESET_VALUE(TIMER_BTN_RESET_VALUE_MS));
    XTmrCtr_Start(timer, TIMER_BTN_CNTR);

    return XST_SUCCESS;
}

int main() {
    XTmrCtr timer;
    
    if (gpio_Init() == XST_SUCCESS && 
            timer_Init(&timer) == XST_SUCCESS) {
        while (1) {
            __asm__ volatile ("wfi");
        }
    }

    return XST_FAILURE;
}