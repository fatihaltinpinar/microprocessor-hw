/* 	@ Author
		Fatih ALTINPINAR
		150180707
*/

int * const SYST_CSR = 0xE000E010;
int * const SYST_RVR = 0xE000E014;
int * const IRQ_SysTick = 0x3C;
const int RVR_Value = 72000;

void SysTick_Handler(){
	int tmp = n; from_stack
	tmp++;;
	n = tmp; from_stack;
}

void Initialize_Timer(){
	*IRQ_SysTick = &SysTick_Handler(); //Address of SysTick_Handler()
	*SYST_CSR |= 0x5;
	*SYST_RVR = 720000;
}

void Start_Timer(){
	*SYST_CSR |= 0x02;
}

void Stop_Timer(){
	*SYST_CSR &= ~(0x02);
}

void delayMilliseconds(int n){
	push(n);
	Start_Timer();
	while(n > 0);
	Stop_Timer();	
}

int main(){
	Initialize_Timer();
	int array[10] = {0};
	for (int i=0; i<10; i++){
		array[i] = i;
		int waitTime = (i+1)*100;
		delayMilliseconds(waitTime);
	}
}