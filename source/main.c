/*************************************************************************************
 * File Name:   main.c
 *
 * Description: This code example showcases how to perform an MQTT over-the-air (OTA) 
 * update using the CYW955913EVK-01 Evaluation Kit. 

 *
 * Related Document: See README.md
 *
 *
 *************************************************************************************
 * Copyright 2021-2024, Cypress Semiconductor Corporation (an Infineon company) or
 * an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
 *
 * This software, including source code, documentation and related
 * materials ("Software") is owned by Cypress Semiconductor Corporation
 * or one of its affiliates ("Cypress") and is protected by and subject to
 * worldwide patent protection (United States and foreign),
 * United States copyright laws and international treaty provisions.
 * Therefore, you may use this Software only as provided in the license
 * agreement accompanying the software package from which you
 * obtained this Software ("EULA").
 * If no EULA applies, Cypress hereby grants you a personal, non-exclusive,
 * non-transferable license to copy, modify, and compile the Software
 * source code solely for use in connection with Cypress's
 * integrated circuit products.  Any reproduction, modification, translation,
 * compilation, or representation of this Software except as specified
 * above is prohibited without the express written permission of Cypress.
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress
 * reserves the right to make changes to the Software without notice. Cypress
 * does not assume any liability arising out of the application or use of the
 * Software or any product or circuit described in the Software. Cypress does
 * not authorize its products for use in any products where a malfunction or
 * failure of the Cypress product may reasonably be expected to result in
 * significant property damage, injury or death ("High Risk Product"). By
 * including Cypress's product in a High Risk Product, the manufacturer
 * of such system or application assumes all risk of such use and in doing
 * so agrees to indemnify Cypress against all liability.
 *******************************************************************************/

/*******************************************************************************
 * Header Files
 *******************************************************************************/
#include "cyhal.h"
#include "cybsp.h"
#include "cy_retarget_io.h"
#include "led_task.h"
#include "ota_task.h"
/*******************************************************************************
 * Macros
 *******************************************************************************/

/*******************************************************************************
 * Global Variables
 *******************************************************************************/
__attribute__((aligned(8)))
uint8_t led_task_stack[LED_TASK_STACK_SIZE] = {0};

__attribute__((aligned(8)))
uint8_t ota_task_stack[OTA_TASK_STACK_SIZE] = {0};
/*******************************************************************************
 * Function Prototypes
 *******************************************************************************/

/*******************************************************************************
 * Function Definitions
 *******************************************************************************/

/*******************************************************************************
 * Function Name: main()
 ********************************************************************************
 * Summary:
 * This is the main function for CPU. It...
 *    1. Initializes the BSP
 *    2. Enables Global interrupt
 *
 * Parameters:
 *  void
 *
 * Return:
 *  void
 *
 *******************************************************************************/
int main(void)
{
    cy_rslt_t result;

    /* Initialize the device and board peripherals */
    result = cybsp_init();

    /* Board init failed. Stop program execution */
    if (result != CY_RSLT_SUCCESS)
    {
        CY_ASSERT(0);
    }

    /* Initialize retarget-io to use the debug UART port */
    result = cy_retarget_io_init(CYBSP_DEBUG_UART_TX, CYBSP_DEBUG_UART_RX,
                                 CY_RETARGET_IO_BAUDRATE);
    /* retarget-io init failed. Stop program execution */
    if (result != CY_RSLT_SUCCESS)
    {
        CY_ASSERT(0);
    }

    /* Enable global interrupts */
    __enable_irq();

    /* \x1b[2J\x1b[;H - ANSI ESC sequence for clear screen */
    printf("\x1b[2J\x1b[;H");

    printf("\r===================================================="
           "===========\n");
    printf("TEST OTA-MQTT Application: OTA Update version: %d.%d.%d\n",
           APP_VERSION_MAJOR, APP_VERSION_MINOR, APP_VERSION_BUILD);
    printf("===============================================================\n\n");

    result = cy_rtos_thread_create(&led_task_handle,
                                   &led_task,
                                   "led task",
                                   &led_task_stack,
                                   LED_TASK_STACK_SIZE,
                                   LED_TASK_PRIORITY,
                                   0);

    if (result != CY_RSLT_SUCCESS)
    {
        CY_ASSERT(0);
    }

    result = cy_rtos_thread_create(&ota_task_handle,
                                   &ota_task,
                                   "ota task",
                                   &ota_task_stack,
                                   OTA_TASK_STACK_SIZE,
                                   OTA_TASK_PRIORITY,
                                   0);

    if (result != CY_RSLT_SUCCESS)
    {
        CY_ASSERT(0);
    }
}

/* [] END OF FILE */
