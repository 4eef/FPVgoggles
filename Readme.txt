FPV goggles power supply and control unit (May-June 2016)

Русский:

Данный проект FPV очков представляет собой простейшую конструкцию бинокулярных очков для просмотра видео. За основу взяты строительные очки и два идентичных черно-белых визора от старых видеокамер. Видеосигнал взят непосредственно с приёмника видеосигнала на диапазон 5,8 ГГц, выход которого имеет вид композитного видеосигнала. Поскольку, приёмник и визоры требуют стабильные параметры питания, была изготовлена плата для управления приёмником и обеспечения питанием всех узлов. Устройство питается от литиевого аккумулятора, имеет простейшие органы управления в виде двух кнопок для переключения каналов и включения/выключения устройства, а также орган отображения информации в виде двух семи-сегментных индикаторов. Организовано слежение за уровнем заряда аккумулятора, и отключение устройства при разряде батареи ниже 3 В. Устройство имеет защиту от переполюсовки питающего напряжения.
Главной целью проекта контроллера было обеспечение питанием визоров от видеокамер и приёмника видеосигнала для их работы, выбор рабочего канала на приёмнике.
Электрическая схема предусматривает возможность замены визора на другой с теми же параметрами питания, принимающего композитный видеосигнал. Также, может быть задействован другой приёмник видеосигнала, поскольку его конфигурирование осуществляется двоичным кодом, а не через последовательный интерфейс. Это определяет универсальность схемы с одной стороны, и её незаконченность с другой. На данный момент, намечена более продвинутая конструкция и схема очков. Текущий проект считается законченным, поскольку, для его модернизации нужно пересматривать всю схемотехнику, конструкцию и идею.
Логика работы устройства:
- при включении отображается напряжение питания в милливольтах на протяжении 3 с. Поступает питающее напряжение на визоры и приёмник, выбран 0-ый канал;
- нажатие кнопок переключает видеочастотный канал вверх/вниз. Выбранный канал отображается 3 с;
- длительное нажатие (более 1 с) включает/отключает подачу питания на визоры и приёмник.
Поскольку, применённый повышающий преобразователь не отключает выход от батареи при его выключении, на выходе преобразователя после его выключение остаётся напряжение батареи минус падение на диоде шоттки. Имейте это в виду, оставляя "отключенный" прибор на длительное время.
Хорошим вариантом отключения устройства является вставление батареи с перепутанной полярностью. Поскольку, устройство имеет защиту от переполюсовки питающего элемента, ему это не навредит, а батарея не будет разряжаться.

English:

This first person view (FPV) goggles project is a simpliest binocular goggles construction to view video. It is based on the construction safety glasses and two identical old camcorder viewfinders. Video receiver module for 5.8 GHz frequencies is used to provide composite video signal for viewfinders. Due to requirements of stable power supply, power supply and cuntrol unit was developed to produce power supply for all circuits and manage receiver control. Device is supplied by single lithium cell, has simpliest controls as two buttons to switch channels and power on/off the device, and display apparatus as two 7-segment indicators. Battery charge level monitoring has been implemented (cuts off below 3 V). Device also has reversed polarity protection.
The main goal of the controller unit is to provide power supply to viewfinders and video receiver and to choose working channel on receiver.
Any viewfinder with capable power supply parameters and video-input can be used. Also different video receiver may be used because channel configuring was done by binary code, not via serial interface. This on one hand determines flexibility of the controller, and on the other - its incompleteness. At the moment more advanced goggles construction is planned. Current project considered as complete because its modernization requires of entire schematics, software and construction revision.
Device operation logic:
- displaying battery's voltage in millivolts for 3 seconds when battery cell is inserted. Power for viewfinders and video receiver is being supplied. 0-th channel is chosen;
- buttons clicks changes channel up/down. Chosen channel is displayed for 3 seconds;
- long click (more than 1 second) switches power supply on/off.
Applied boost-converter does not cuts off battery from its output when switched off, so converter's output has a battery voltage minus schottky diode voltage drop. Take this into account when leaving the "powered off" device for a while.
Good variant of cutting the power supply is to insert the cell with reversed polarity. Device has reversed polarity protection, so it will not harm the device, and battery do not lose its charge.
