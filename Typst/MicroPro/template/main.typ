#import "../lib.typ": *
#page(
  margin: (x: 0cm, y: 0cm),  // 封面单独设置边距
  header: none,  // 封面页不需要页眉
  footer: none,  // 封面页不需要页码
  {
    image("cover.pdf", width: 100%)
  }
)


#show: project.with(
  title: "微机原理与系统设计课程设计实验报告",
  subtitle: "课题六：键盘电子乐器演奏程序设计",
  author: "作者：张书语",
  date: auto,
  // abstract: [
  //   本文档展示了 EasyPaper 模板的主要功能，包括题目框、解答框、三线表格、数学公式等学术组件。
  // ],
  // keywords: ("Typst", "模板", "学术写作"),
)


= 课程任务与目标

== 课程任务

1. 完成一个小型微机应用系统题目的设计。
2. 搭建开发环境进行软硬件实现并验证。

== 课程目标
1. 深入理解和掌握微型计算机应用系统的硬件组成与设计方法。
2. 锻炼程序设计及系统调试能力，提高工程思维及运用专业知识解决问题的能力。
3. 理解多学科背景下的团队中每个角色的定位与责任，胜任个人承担的角色任务，听取并综合团队成员的意见与建议，具有良好的执行能力，完成团队的协同工作。
4. 能够将计算机专业知识应用到撰写报告和设计文稿中，并能够就相关问题陈述发言、清晰表达或回应指令。


= 实验目的与内容

== 实验设计目的
1. 了解利用8253定时器产生不同音符的原理及方法，设计简单的电子乐器演奏程序。 
2. 加深对上位机通信过程的理解，编写相应的程序实现电子乐器的功能。
3. 初步掌握电子乐器演奏程序的设计方法，培养分析问题和解决问题的能力。

== 实验内容

设计一个可以通过实验箱键盘或者鼠标演奏不同音乐的控制系统，系统通过按下实验箱键盘或鼠标点击琴键模仿电子琴键驱动实验箱上的蜂鸣器发声，实现演奏音乐的功能。

== 基本功能要求
1. 音调：能够演奏C调包含高、中、低音的不同节拍的乐曲，音调与频率的对应关系如下：

  - 中音：1-261Hz，2-293Hz，3-329Hz，4-349Hz，5-392Hz，6-440Hz，7-493Hz
  - 低8度音：基本音频率/2,例如低音1为261/2=130.5Hz
  - 高8度音：基本音频率x2，例如高音1为261x2=522Hz 

    
2. 节拍：每个音的长短由音符的节拍来控制。

在一张乐谱中，经常会看到：1=C 3/4、1=G 4/4等，这里1=C、1=G表示乐谱的曲调，它是用来确定基音的；3/4、4/4就是用来表示节拍的。以3/4为例，它表示乐谱中以四分音符为节拍，每一节拍有三拍。

通常一拍的时长为400-500毫秒。以一拍的时长为400为例，当四分音符为节拍时，四分音符的时长就为400毫秒，八分音符的时长就为200毫秒，16分音符的时长为100毫秒。

3. 附加功能
  - 增加自动演奏乐曲功能。当按下P键后，自动播放一首乐曲，曲长大于20秒。 
  - 增加一个音调D，当从C调改为D调后，演奏音按照D调(比 C高一个调)发音。


= 实验环境与仪器

== 实验环境
1. 星研集成环境软件
2. 串口助手运行程序
3. 模拟电子琴上位机程序

== 实验仪器
1. 实验箱：包含8253定时器、8250串口通信接口、RS-232串口等硬件模块。
  - 8253定时器：用于产生不同频率的音调。
  -  8250串口通信接口：用于实现上位机与电子琴的通信。
  -  RS-232串口：用于连接上位机和电子琴进行数据传输。
  -  蜂鸣器：用于发出声音。
2. 鼠标：用于点击琴键进行演奏。
3. 计算机：用于编写和运行演奏程序。


#figure(
  image("./assets/实验箱构成2.png", width: 90%, height: 35%),
  caption: [实验箱硬件构成图],
)

#figure(
  image("./assets/实验箱各模块外观.jpg", width: 100%, height: 45%),
  caption: [实验箱各模块外观图],
)



= 实验原理

== 8253定时器原理
8253定时器是一种可编程的计数器芯片，具有三个独立的计数器，每个计数器可以配置为不同的工作模式。通过设置计数器的初值和工作模式，可以产生不同频率的输出信号，从而实现不同音调的发声。在本次实验中，将使用8253的计数器0来产生不同频率的音调，以实现电子乐器的演奏功能。

#figure(
  image("./assets/8253.png"),
  caption: [8253定时器电路图],
)

8253定时器的工作模式包括：
1. 模式0：中断请求模式，计数器在计数到0时产生中断请求。
2. 模式1：硬件触发单次计数模式，计数器在接收到硬件触发信号后开始计数，计数到0后停止。
3. 模式2：硬件触发连续计数模式，计数器在接收到硬件触发信号后开始计数，计数到0后自动重新加载初值继续计数。
4. 模式3：软件触发连续计数模式，计数器在接收到软件触发信号后开始计数，计数到0后自动重新加载初值继续计数。通过选择合适的工作模式和设置初值，可以实现不同频率的输出信号，从而驱动蜂鸣器发出不同音调的声音。

8253定时器的计数值本质上是定时器的周期，周期越短，频率越高，音调越高；周期越长，频率越低，音调越低。通过调整计数值，可以实现不同频率的输出信号，从而实现不同音调的发声。

== 上位机通信原理
上位机通信是指计算机与外部设备之间的数据交换过程。在本实验中，计算机通过串口与实验箱进行通信，发送控制指令来驱动8253定时器产生相应的音调。

通信过程中需要设置正确的波特率、数据位、停止位和校验位等参数，以确保数据的正确传输。通过编写相应的程序，可以实现对实验箱的控制，从而实现电子乐器的演奏功能。

#figure(
  image("./assets/通信协议.png"),
  caption: [键盘电子琴上位机通信协议],
)

== 8250串口通信接口原理
8250串口通信接口是一种常用的串行通信接口，具有发送和接收功能。在本实验中，8250串口通信接口用于实现计算机与实验箱之间的数据传输。通过配置8250串口通信接口的寄存器，可以实现数据的发送和接收，从而实现对实验箱的控制。

#figure(
  image("./assets/8250.png"),
  caption: [8250串口通信接口电路图],
)

== RS-232串口原理
RS-232串口是一种常用的串行通信接口标准，定义了电气特性、信号定义和连接器类型等规范。在本实验中，RS-232串口用于连接计算机和实验箱进行数据传输。
#figure(
  image("./assets/RS232.png"),
  caption: [RS-232串口电路图],
)

== 蜂鸣器原理
蜂鸣器是一种能够发出声音的电子元件，通常由一个振荡器和一个发声单元组成。在本实验中，蜂鸣器用于发出不同频率的声音，以实现电子乐器的演奏功能。通过控制8253定时器的输出频率，可以驱动蜂鸣器发出不同音调的声音，从而实现电子乐器的演奏功能。
#figure(
  image("./assets/蜂鸣器.png"),
  caption: [蜂鸣器电路图],
)

== 发声原理
当8253定时器输出特定频率的信号时，驱动蜂鸣器发出相应频率的声音。通过调整8253定时器的计数器初值和工作模式，可以产生不同频率的输出信号，从而实现不同音调的发声。


= 实验设计

== 设计思路
首先通过上位机通信协议，与RS-232串口建立通信连接，确保计算机能够正确发送控制指令到实验箱，8250串口通信接口负责数据的发送和接收。然后根据8253定时器的工作原理，编写程序控制定时器产生不同频率的输出信号，从而驱动蜂鸣器发出不同音调的声音。

== 硬件设计
#figure(
  image("./assets/硬件连接.jpg", width: 90%, height: 40%),
  caption: [硬件连接图],
)

== 软件设计

=== 延迟函数
delay函数用于实现音符的节拍控制，通过设置不同的延迟时间来控制每个音符的发声时长。
#problem[
  该函数通过循环实现延迟，循环次数越多，延迟时间越长。通过调整循环次数，可以实现不同节拍的控制。此处的循环次数通过多次实验确定，可以发现，不同实验箱的毫秒延迟所需循环次数大有不同，与实验箱的处理器性能和系统负载等因素有关。
]

```c
void delay_ms(u16 ms) {
  // 8086 上使用简单空转延时（近似 1ms）
  // 循环常数与实验箱主频有关
  volatile u16 i;
  while (ms--) {
    for (i = 0; i < 30000; i++) {
      ;
    }
  }
}
```



=== 音调控制函数

该函数用于根据输入的频率和节拍计算8253的计数器初值，从而实现不同音调的发声。

在函数中，首先判断输入的频率和节拍是否为0，如果是，则关闭输出（静音）。否则，根据频率计算计数器初值，并通过8253定时器的寄存器设置相应的工作模式和计数值来产生所需的音调。最后，通过调用延迟函数来控制音符的节拍，延迟结束后停止输出。

#problem[
  初始化判断并静音，既完成了8253的初始化工作，也可以避免在输入无效参数时产生噪音。避免单独封装8253初始化函数，重复调用产生冗余。

]

#figure(
  
  image("./assets/ring.png", width: 50%, height: 50%),
  caption: [音调控制函数流程图],
)


```c
void ring(u16 freq, u16 duration) {
  u16 count0, count1;

  // freq=0 或 duration=0：关闭输出（静音）
  if (freq == 0 || duration == 0) {
    outportb(COM_ADDR, 0x36); // T0, lobyte/hibyte, mode3, binary
    outportb(T0_ADDR, 0);     // 计数值为 0 表示停止输出
    return;
  }

  count0 = (u16)(2000000UL / freq);
  if (count0 == 0) count0 = 1;

  outportb(COM_ADDR, 0x36);     // T0, lobyte/hibyte, mode3, binary
  outportb(T0_ADDR, count0 & 0xFF);         // 低字节
  outportb(T0_ADDR, (count0 >> 8) & 0xFF);  // 高字节

  // 延迟 duration 毫秒后停止输出
  delay_ms(duration);

  outportb(COM_ADDR, 0x36); // T0, lobyte/hibyte, mode3, binary
  outportb(T0_ADDR, 0);     // 计数值为 0 表示停止输出
}
```

=== 音符播放函数
该函数用于根据输入的音符编号、节拍和模式来播放相应的音调。根据输入的模式（C调或D调），函数会根据预设的频率表来调用音调控制函数来发出相应的声音。

#figure(
  
  image("./assets/play.png", width: 45%, height: 40%),
  caption: [音符播放函数流程图],
)


```c
void play(u8 num, u16 duration, u8 mode) {
  if (mode == 'C') {
    switch (num) {
      case 1 : ring(C_DO  / 2, duration); break;
      case 2 : ring(C_RE  / 2, duration); break;
      case 3 : ring(C_MI  / 2, duration); break;
      case 4 : ring(C_FA  / 2, duration); break;
      case 5 : ring(C_SOL / 2, duration); break;
      case 6 : ring(C_LA  / 2, duration); break;
      case 7 : ring(C_SI  / 2, duration); break;
      case 8 : ring(C_DO , duration); break;
      case 9 : ring(C_RE , duration); break;
      case 10: ring(C_MI , duration); break;
      case 11: ring(C_FA , duration); break;
      case 12: ring(C_SOL, duration); break;
      case 13: ring(C_LA , duration); break;
      case 14: ring(C_SI , duration); break;
      case 15: ring(C_DO  * 2, duration); break;
      case 16: ring(C_RE  * 2, duration); break;
      case 17: ring(C_MI  * 2, duration); break;
      case 18: ring(C_FA  * 2, duration); break;
      case 19: ring(C_SOL * 2, duration); break;
      case 20: ring(C_LA  * 2, duration); break;
      case 21: ring(C_SI  * 2, duration); break;
      default: ring(0, duration); break; // 其他编号设置为无声
    }
  } else {
    switch (num) {
      case 1 : ring(D_DO  / 2, duration); break;
      case 2 : ring(D_RE  / 2, duration); break;
      case 3 : ring(D_MI  / 2, duration); break;
      case 4 : ring(D_FA  / 2, duration); break;
      case 5 : ring(D_SOL / 2, duration); break;
      case 6 : ring(D_LA  / 2, duration); break;
      case 7 : ring(D_SI  / 2, duration); break;
      case 8 : ring(D_DO , duration); break;
      case 9 : ring(D_RE , duration); break;
      case 10: ring(D_MI , duration); break;
      case 11: ring(D_FA , duration); break;
      case 12: ring(D_SOL, duration); break;
      case 13: ring(D_LA , duration); break;
      case 14: ring(D_SI , duration); break;
      case 15: ring(D_DO  * 2, duration); break;
      case 16: ring(D_RE  * 2, duration); break;
      case 17: ring(D_MI  * 2, duration); break;
      case 18: ring(D_FA  * 2, duration); break;
      case 19: ring(D_SOL * 2, duration); break;
      case 20: ring(D_LA  * 2, duration); break;
      case 21: ring(D_SI  * 2, duration); break;
      default: ring(0, duration); break; // 其他编号设置为无声
    }
  }
}
```

=== 通信数据处理
1. 8250初始化：
该函数根据上位机通信协议的数据传输要求，初始化8250串口通信接口的寄存器设置，以确保正确的数据传输。
```c
// 初始化 8250
void init8250() {
	outportb(ISR, 0x6);
	outportb(LCR, 0x83);	// 允许访问波特率因子寄存器
	outportb(DLL, 40);		// 波特率设为4800=(3.072*1000000/16)/DLMDLL
	outportb(DLM, 0x0);
	outportb(LCR, 0x1b);	// 不允许访问波特率;数据格式为8数据位,1停止位,偶校验
}
```

2. 接受字节函数：
该函数用于从8250串口通信接口接收一个字节的数据，并返回接收到的数据值。通过持续检测缓冲区数据的最后一位，判断是否有数据可供读取，如果有，则从数据寄存器读取数据并返回。

```c
u8 getc() {
  // 等待接收缓冲区有数据
	while ((inportb(LSR) & 1) == 0) {;} // 检测最后一位
	return inportb(RHR);
}

```

=== 自动演奏函数
该函数用于实现自动演奏乐曲的功能，通过预设的乐曲数据，自动调用音符播放函数来演奏乐曲。乐曲数据存储在数组中，包含每个音符的编号、节拍和模式。函数通过循环遍历乐曲数据，依次调用音符播放函数来实现自动演奏的功能。

此处内置小星星的旋律。
#problem[
  为了优化歌曲播放效果，该函数中调整节奏，通过设置长短音和自然停顿，优化演奏效果。

]

```c
void little_star(u8 mode) {
  // 1 1 5 5 6 6 5
  // 4 4 3 3 2 2 1
  // 5 5 4 4 3 3 2
  // 5 5 4 4 3 3 2
  // 1 1 5 5 6 6 5
  // 4 4 3 3 2 2 1
  u8 melody[] = {
    8, 8, 12, 12, 13, 13, 12,
    11, 11, 10, 10, 9, 9, 8,
    12, 12, 11, 11, 10, 10, 9,
    12, 12, 11, 11, 10, 10, 9,
    8, 8, 12, 12, 13, 13, 12,
    11, 11, 10, 10, 9, 9, 8
  };
  u16 i;
  u16 count = sizeof(melody) / sizeof(melody[0]);

  // 节奏优化：加入长短音和自然停顿，让旋律更流畅
  // 0=短音，1=长音（句末/小节末）
  u8 long_note[] = {
    0, 0, 0, 0, 0, 0, 1,
    0, 0, 0, 0, 0, 0, 1,
    0, 0, 0, 0, 0, 0, 1,
    0, 0, 0, 0, 0, 0, 1,
    0, 0, 0, 0, 0, 0, 1,
    0, 0, 0, 0, 0, 0, 1
  };

  u16 short_dur = 260; // 短音时值
  u16 long_dur  = 460; // 长音时值
  u16 short_gap = 40;  // 短停顿
  u16 long_gap  = 140; // 句末停顿

  for (i = 0; i < count; i++) {
    u16 dur = long_note[i] ? long_dur : short_dur;
    u16 gap = long_note[i] ? long_gap : short_gap;

    play(melody[i], dur, mode);
    ring(0, gap); // 音符间留白，避免粘连
  }
}
```

=== 主程序

主程序调用8250初始化函数，并等待上位机传送数据。当接收到特定的控制指令时，根据指令内容调用相应的函数来实现电子乐器的演奏功能。

#figure(
  
  image("./assets/main.png", width: 80%, height: 60%),
  caption: [主程序流程图],
)
```c
int main() {
  u8 num;
  u16 duration;
  u8 mode;
  init8250();

  duration = 200; // 设置默认持续时间
  mode = 'C';     // 设置默认调式
  while (1) {
    // 确保是从上位机获取到的数据
    if (getc() == 0x55 && getc() == 0xAA) {
      num = getc(); // 获取音调编号
      switch (num) {
        case 'C': mode = num; break;
        case 'D': mode = num; break;
        case 'P': little_star(mode); break;
        default: play(num, duration, mode); break; // 其他编号设置为无声
      }
    }
  }
}
```

=== 完整可执行的源程序

#problem[
  完整可执行的源代码已发送邮箱，此处省略。

]



= 实验现象
1. 当鼠标点击琴键时，能够听到相应的音调发出，音调与预设的频率表一致。
2. 当按下P键后，能够自动播放预设的乐曲，且在播放期间点击琴键，不会打断乐曲的演奏。  
3. 当从C调改为D调后，演奏的音调明显升高，符合D调的频率要求。



= 问题分析

== 问题与解决

1. 由于星研集成环境中，浮点数的运算较为复杂，没有可以支持的库函数，程序中频率全部进行取整操作，导致8253定时器的计数值计算存在误差，实际发出的音调与预设频率不完全一致。
2. 在上位机通信过程中，刚开始借助示例代码检测十个传入的字节，限制了单字节的传输，增加代码复杂度。后面将其更改为逐个检验传输字节，通过检测特定的起始字节（0x55和0xAA）来确定数据的开始，简化了代码逻辑。
3. 在最初的方法设计中，采取实验箱键盘和鼠标点击两种输入方式来控制音符的播放，延迟函数则需要利用定时器中断来实现，在使用多个计数器控制时，程序设计复杂度较高。后面将输入方式统一为鼠标点击，简化了输入处理逻辑，同时利用软件的延迟函数来控制节拍计。

== 键盘设计
此处对键盘控制发声的设计进行简要介绍，由于时间原因，尚未在实验箱上进行验证。

=== 8255初始化函数
使用8255的一个端口作为输入，连接实验箱键盘的行线，另一个端口作为输出，连接键盘的列线。通过扫描行线和列线的状态来检测按键的按下情况。

```c
void init_8255()
{
    outportb(CON_Addr, 0x89);	// 1000 1001B：PA口输出，PB口输出，PC口输入
}
```

=== 键盘扫描函数
通过扫描8255的输入端口，检测按键的按下情况，并根据按键的编号调用相应的函数来实现音符的播放。

```c

void DIR()
{
	u8 i, dig = 0xfe; // 第1位数码管1111 1110

    // 段码表对应：0 1 2 3 4 5 6 7 8 9 A B C D E F 全灭
	u8 SegArray[]={0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8,
			   0x80, 0x90, 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E, 0xFF}; 

	for (i = 0 ; i < 8; i++)
	{
		outportb(PA_Addr, SegArray[buffer[i]]);		// 输出段码
		outportb(PB_Addr, dig);		// 输出位选		
		delay(3);									
		outportb(PB_Addr, 0xff);
		dig = ((dig << 1) | 1);     // 移位选择下一位
	}
}
```

=== 按键检测函数
通过检测8255的输入端口的状态，判断哪个按键被按下，并根据按键的编号调用相应的函数来实现音符的播放。

```c
u8 AllKey()
{
	u8 i;
	outportb(PB_Addr, 0x0);     // 所有行输出低电平
	i = (~inportb(PC_Addr) & 0x0F);  // 读取两列状态，取反后只取低2位
	return i;  // 返回非0表示有键按下
}
```

=== 按键识别函数
该函数通过两次检测来确认按键的按下，避免了按键抖动带来的误判。通过逐行扫描的方式来确定哪个按键被按下，并根据按键的编号调用相应的函数来实现音符的播放。

```c
u8 key()
{
	u8 i, j, keyResult;
	u8 isKey = 0;
	while(!isKey)
	{
        // 第一次检测
		if (AllKey() == 0)
		{
			DIR();      // 调用两次显示函数，保持显示稳定
			DIR();
			continue;       // 继续检测
		}
        //第一次检测到有按键, 通过显示函数消耗时间
		DIR();
		DIR();

        // 第二次检测
		if (AllKey() == 0)      //第二次检测没有按键,可能抖动
			continue;
        
        // 确认有按键，逐行扫描
		i = 0xfe;  // 初始行扫描码：1111 1110（第0行低电平）
		keyResult = 0;

		do
		{
			outportb(PB_Addr, i);  // 将当前行设为低电平
			j = (~inportb(PC_Addr)) & 0x3F;  // 读取列状态并取反（高电平表示有按键）
			if (j)
			{
				isKey = 1;
				if(j & 0x01) keyResult += 0;      // 第0列
                else if(j & 0x02) keyResult += 8;  // 第1列
                else if(j & 0x04) keyResult += 16; // 第2列
                else if(j & 0x08) keyResult += 24; // 第3列
			}
			else						// 该行没有按键
			{
				keyResult++;			// 键值加1，进入下一行
				i = ((i << 1) | 1);
			}
		}while(!isKey  && (i != 0xff));
	}

	if (isKey)
	{
		while(AllKey())		// 等待按键释放
		{
			DIR();      // 维持显示
		}
	}
	return keyResult;
}
```

=== 完整可执行的源程序
#problem[
  完整可执行的源代码已发送邮箱，此处省略。

]

= 心得体会
1. 通过本次课程设计，我深入理解了微机原理与系统设计的相关知识，掌握了8253定时器、8250串口通信接口和RS-232串口的工作原理和应用方法。

2. 在实验过程中，通过解决频率计算误差、通信协议设计和输入处理等问题，分析和调整，最终成功实现了键盘电子乐器的演奏功能。这次课程设计不仅锻炼了我的编程能力和系统设计能力，还提高了我解决问题的能力和团队协作能力。我相信这些经验将对我未来的学习和工作产生积极的影响。


