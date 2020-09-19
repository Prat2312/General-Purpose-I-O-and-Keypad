/***********************************************************************************************
*    Start Assembly.c
*    Used to jump the the assembly source code for Exp#1
*    
*    Project members: Roger Younger
*
*
*    Revision 1.0       Feb 13, 2020
*
************************************************************************************************/

extern void ASSEMBLY_INIT (void);
extern void UPB_B1_INIT(void);
extern int CHECK_FOR_PINPRESS(void);
extern void LCD_DISPLAY(int LCD_DISPLAY_VAL);
extern void DELAY_50ms(void);
extern void GREEN_LED0(int LED_STATE);
extern void KEYPAD_INIT(void);
extern int KEYPAD_SCAN(void);
int main (void)
{
	int sw_press,lcd_count=0,keypad_lcd_val;
	ASSEMBLY_INIT();
	UPB_B1_INIT();
	KEYPAD_INIT();
	while(1)
		{
			/*sw_press=CHECK_FOR_PINPRESS();
			if(sw_press==1)
				{
					LCD_DISPLAY(lcd_count);
					lcd_count++;
				}*/
			
			keypad_lcd_val=KEYPAD_SCAN();
			if(keypad_lcd_val<16){
				LCD_DISPLAY(keypad_lcd_val);
			}
			
			/*switch(keypad_lcd_val)
					{
						case 0:LCD_DISPLAY(0x00);
									 GREEN_LED0(1);
									 lcd_count = 0;
						break;
			
						case 1:LCD_DISPLAY(0x01);
									 lcd_count = 1;	
						break;
				
						case 2:LCD_DISPLAY(0x02);
		    					 lcd_count = 2;
						break;
				
						case 3:LCD_DISPLAY(0x03);
								   lcd_count = 3;
						break;
				
						case 4:LCD_DISPLAY(0x04);
									 lcd_count = 4;
						break;
				
						case 5:LCD_DISPLAY(0x05);
									 lcd_count = 5;
						break;
					
						case 6:LCD_DISPLAY(0x06);
									 lcd_count = 6;
						break;
				
						case 7:LCD_DISPLAY(0x07);
									 lcd_count = 7;
						break;
							
						case 8:LCD_DISPLAY(0x08);
									 lcd_count = 8;
						break;
					
						case 9:LCD_DISPLAY(0x09);
									 lcd_count = 9; 
						break;	
						
						case 10:LCD_DISPLAY(0x01); // Assign A as 01
									  lcd_count = 1;
						break;
						
						case 11:LCD_DISPLAY(0x02);  // Assign B as 02
										lcd_count = 2;
						break;
						
						case 12:LCD_DISPLAY(0x04);	// Assign C as 03
										lcd_count = 3;
						break;
						
						case 13:LCD_DISPLAY(0x08);	// Assign D as 04
										lcd_count = 4;
						break;
						
						case 14:LCD_DISPLAY(0x0E);	// Assign D as 04
										//lcd_count = 0x0E;
										sw_press=CHECK_FOR_PINPRESS(); // set in decrement mode or pin *
										while(sw_press==1)
											{
												lcd_count--;
												LCD_DISPLAY(lcd_count);
												break;
											}
						break;
											
						case 15:LCD_DISPLAY(0x0F);	// Assign D as 04
										//lcd_count = 0x0F;
										sw_press=CHECK_FOR_PINPRESS(); // set in increment mode or pin # 
										while(sw_press==1)
											{
												lcd_count++;
												LCD_DISPLAY(lcd_count);
												break;
											}
						break;					
					}*/
		}
}

