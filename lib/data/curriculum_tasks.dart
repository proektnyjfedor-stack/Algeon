import '../models/task.dart';

/// Дополнительные темы по программе учебников 1–11 классов
final List<Task> curriculumTasks = [

  // ==================== КЛАСС 1 ====================

  // --- Состав числа ---
  Task(id:'cur_g1_s1',grade:1,topic:'Состав числа',question:'Число 7 = 3 + ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g1_s2',grade:1,topic:'Состав числа',question:'Число 8 = 5 + ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g1_s3',grade:1,topic:'Состав числа',question:'Число 6 = ? + 4',type:TaskType.multipleChoice,options:['1','2','3','4'],answer:'2'),
  Task(id:'cur_g1_s4',grade:1,topic:'Состав числа',question:'Число 9 = 4 + ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g1_s5',grade:1,topic:'Состав числа',question:'Сколько добавить к 3, чтобы получить 8?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g1_s6',grade:1,topic:'Состав числа',question:'Число 10 = 6 + ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g1_s7',grade:1,topic:'Состав числа',question:'7 = 2 + ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g1_s8',grade:1,topic:'Состав числа',question:'Число 5 можно составить как: 2 + ?',type:TaskType.textInput,answer:'3'),

  // --- Числа 11–20 ---
  Task(id:'cur_g1_n1',grade:1,topic:'Числа 11-20',question:'Сколько единиц в числе 15?',type:TaskType.multipleChoice,options:['3','4','5','6'],answer:'5'),
  Task(id:'cur_g1_n2',grade:1,topic:'Числа 11-20',question:'Какое число стоит между 13 и 15?',type:TaskType.textInput,answer:'14'),
  Task(id:'cur_g1_n3',grade:1,topic:'Числа 11-20',question:'Назови число после 17',type:TaskType.textInput,answer:'18'),
  Task(id:'cur_g1_n4',grade:1,topic:'Числа 11-20',question:'Какое число на 1 меньше 20?',type:TaskType.textInput,answer:'19'),
  Task(id:'cur_g1_n5',grade:1,topic:'Числа 11-20',question:'Сколько десятков в числе 16?',type:TaskType.multipleChoice,options:['0','1','2','6'],answer:'1'),
  Task(id:'cur_g1_n6',grade:1,topic:'Числа 11-20',question:'11 + 0 = ?',type:TaskType.textInput,answer:'11'),
  Task(id:'cur_g1_n7',grade:1,topic:'Числа 11-20',question:'Какое число между 18 и 20?',type:TaskType.textInput,answer:'19'),
  Task(id:'cur_g1_n8',grade:1,topic:'Числа 11-20',question:'Разложи число 14: 10 + ?',type:TaskType.textInput,answer:'4'),

  // --- Сложение до 20 ---
  Task(id:'cur_g1_a1',grade:1,topic:'Сложение до 20',question:'8 + 5 = ?',type:TaskType.textInput,answer:'13'),
  Task(id:'cur_g1_a2',grade:1,topic:'Сложение до 20',question:'9 + 4 = ?',type:TaskType.textInput,answer:'13'),
  Task(id:'cur_g1_a3',grade:1,topic:'Сложение до 20',question:'7 + 6 = ?',type:TaskType.textInput,answer:'13'),
  Task(id:'cur_g1_a4',grade:1,topic:'Сложение до 20',question:'11 + 7 = ?',type:TaskType.textInput,answer:'18'),
  Task(id:'cur_g1_a5',grade:1,topic:'Сложение до 20',question:'9 + 9 = ?',type:TaskType.textInput,answer:'18'),
  Task(id:'cur_g1_a6',grade:1,topic:'Сложение до 20',question:'14 + 5 = ?',type:TaskType.textInput,answer:'19'),
  Task(id:'cur_g1_a7',grade:1,topic:'Сложение до 20',question:'6 + 8 = ?',type:TaskType.textInput,answer:'14'),
  Task(id:'cur_g1_a8',grade:1,topic:'Сложение до 20',question:'13 + 4 = ?',type:TaskType.textInput,answer:'17'),

  // --- Вычитание до 20 ---
  Task(id:'cur_g1_b1',grade:1,topic:'Вычитание до 20',question:'15 - 7 = ?',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g1_b2',grade:1,topic:'Вычитание до 20',question:'12 - 5 = ?',type:TaskType.textInput,answer:'7'),
  Task(id:'cur_g1_b3',grade:1,topic:'Вычитание до 20',question:'18 - 9 = ?',type:TaskType.textInput,answer:'9'),
  Task(id:'cur_g1_b4',grade:1,topic:'Вычитание до 20',question:'17 - 8 = ?',type:TaskType.textInput,answer:'9'),
  Task(id:'cur_g1_b5',grade:1,topic:'Вычитание до 20',question:'14 - 6 = ?',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g1_b6',grade:1,topic:'Вычитание до 20',question:'20 - 13 = ?',type:TaskType.textInput,answer:'7'),
  Task(id:'cur_g1_b7',grade:1,topic:'Вычитание до 20',question:'16 - 7 = ?',type:TaskType.textInput,answer:'9'),
  Task(id:'cur_g1_b8',grade:1,topic:'Вычитание до 20',question:'11 - 4 = ?',type:TaskType.textInput,answer:'7'),

  // ==================== КЛАСС 2 ====================

  // --- Таблица умножения ---
  Task(id:'cur_g2_m1',grade:2,topic:'Таблица умножения',question:'7 × 8 = ?',type:TaskType.textInput,answer:'56'),
  Task(id:'cur_g2_m2',grade:2,topic:'Таблица умножения',question:'9 × 6 = ?',type:TaskType.textInput,answer:'54'),
  Task(id:'cur_g2_m3',grade:2,topic:'Таблица умножения',question:'8 × 7 = ?',type:TaskType.textInput,answer:'56'),
  Task(id:'cur_g2_m4',grade:2,topic:'Таблица умножения',question:'6 × 9 = ?',type:TaskType.textInput,answer:'54'),
  Task(id:'cur_g2_m5',grade:2,topic:'Таблица умножения',question:'7 × 7 = ?',type:TaskType.textInput,answer:'49'),
  Task(id:'cur_g2_m6',grade:2,topic:'Таблица умножения',question:'8 × 8 = ?',type:TaskType.textInput,answer:'64'),
  Task(id:'cur_g2_m7',grade:2,topic:'Таблица умножения',question:'9 × 9 = ?',type:TaskType.textInput,answer:'81'),
  Task(id:'cur_g2_m8',grade:2,topic:'Таблица умножения',question:'6 × 7 = ?',type:TaskType.textInput,answer:'42'),

  // --- Сложение двузначных ---
  Task(id:'cur_g2_a1',grade:2,topic:'Сложение двузначных',question:'23 + 45 = ?',type:TaskType.textInput,answer:'68'),
  Task(id:'cur_g2_a2',grade:2,topic:'Сложение двузначных',question:'37 + 24 = ?',type:TaskType.textInput,answer:'61'),
  Task(id:'cur_g2_a3',grade:2,topic:'Сложение двузначных',question:'46 + 38 = ?',type:TaskType.textInput,answer:'84'),
  Task(id:'cur_g2_a4',grade:2,topic:'Сложение двузначных',question:'55 + 27 = ?',type:TaskType.textInput,answer:'82'),
  Task(id:'cur_g2_a5',grade:2,topic:'Сложение двузначных',question:'68 + 15 = ?',type:TaskType.textInput,answer:'83'),
  Task(id:'cur_g2_a6',grade:2,topic:'Сложение двузначных',question:'74 + 19 = ?',type:TaskType.textInput,answer:'93'),
  Task(id:'cur_g2_a7',grade:2,topic:'Сложение двузначных',question:'49 + 33 = ?',type:TaskType.textInput,answer:'82'),
  Task(id:'cur_g2_a8',grade:2,topic:'Сложение двузначных',question:'56 + 44 = ?',type:TaskType.textInput,answer:'100'),

  // --- Вычитание двузначных ---
  Task(id:'cur_g2_sb1',grade:2,topic:'Вычитание двузначных',question:'87 - 34 = ?',type:TaskType.textInput,answer:'53'),
  Task(id:'cur_g2_sb2',grade:2,topic:'Вычитание двузначных',question:'62 - 25 = ?',type:TaskType.textInput,answer:'37'),
  Task(id:'cur_g2_sb3',grade:2,topic:'Вычитание двузначных',question:'91 - 47 = ?',type:TaskType.textInput,answer:'44'),
  Task(id:'cur_g2_sb4',grade:2,topic:'Вычитание двузначных',question:'74 - 36 = ?',type:TaskType.textInput,answer:'38'),
  Task(id:'cur_g2_sb5',grade:2,topic:'Вычитание двузначных',question:'80 - 53 = ?',type:TaskType.textInput,answer:'27'),
  Task(id:'cur_g2_sb6',grade:2,topic:'Вычитание двузначных',question:'65 - 28 = ?',type:TaskType.textInput,answer:'37'),
  Task(id:'cur_g2_sb7',grade:2,topic:'Вычитание двузначных',question:'100 - 43 = ?',type:TaskType.textInput,answer:'57'),
  Task(id:'cur_g2_sb8',grade:2,topic:'Вычитание двузначных',question:'76 - 49 = ?',type:TaskType.textInput,answer:'27'),

  // --- Уравнения 2 класс ---
  Task(id:'cur_g2_e1',grade:2,topic:'Уравнения 2 класс',question:'x + 5 = 12. Найди x',type:TaskType.textInput,answer:'7'),
  Task(id:'cur_g2_e2',grade:2,topic:'Уравнения 2 класс',question:'x - 3 = 8. Найди x',type:TaskType.textInput,answer:'11'),
  Task(id:'cur_g2_e3',grade:2,topic:'Уравнения 2 класс',question:'14 - x = 6. Найди x',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g2_e4',grade:2,topic:'Уравнения 2 класс',question:'x + 7 = 15. Найди x',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g2_e5',grade:2,topic:'Уравнения 2 класс',question:'x - 9 = 4. Найди x',type:TaskType.textInput,answer:'13'),
  Task(id:'cur_g2_e6',grade:2,topic:'Уравнения 2 класс',question:'20 - x = 8. Найди x',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g2_e7',grade:2,topic:'Уравнения 2 класс',question:'x + 13 = 25. Найди x',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g2_e8',grade:2,topic:'Уравнения 2 класс',question:'x - 15 = 6. Найди x',type:TaskType.textInput,answer:'21'),

  // --- Деньги и цена ---
  Task(id:'cur_g2_mo1',grade:2,topic:'Деньги и цена',question:'Книга стоит 25 р., тетрадь — 13 р. Сколько вместе?',type:TaskType.textInput,answer:'38'),
  Task(id:'cur_g2_mo2',grade:2,topic:'Деньги и цена',question:'Карандаш стоит 5 р. Сколько стоят 4 карандаша?',type:TaskType.textInput,answer:'20'),
  Task(id:'cur_g2_mo3',grade:2,topic:'Деньги и цена',question:'У Пети 50 р., он потратил 27 р. Сколько осталось?',type:TaskType.textInput,answer:'23'),
  Task(id:'cur_g2_mo4',grade:2,topic:'Деньги и цена',question:'Конфета стоит 8 р. Сколько конфет можно купить на 40 р.?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g2_mo5',grade:2,topic:'Деньги и цена',question:'Альбом 35 р., ластик 7 р. Сколько стоят оба?',type:TaskType.textInput,answer:'42'),
  Task(id:'cur_g2_mo6',grade:2,topic:'Деньги и цена',question:'У мамы 100 р. Хлеб 30 р., молоко 45 р. Сколько осталось?',type:TaskType.textInput,answer:'25'),
  Task(id:'cur_g2_mo7',grade:2,topic:'Деньги и цена',question:'3 ручки стоят 18 р. Сколько стоит одна ручка?',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g2_mo8',grade:2,topic:'Деньги и цена',question:'Ваня купил 5 яблок по 4 р. Сколько он заплатил?',type:TaskType.textInput,answer:'20'),

  // ==================== КЛАСС 3 ====================

  // --- Числа до 1000 ---
  Task(id:'cur_g3_n1',grade:3,topic:'Числа до 1000',question:'5 сотен, 3 десятка, 7 единиц — это число:',type:TaskType.multipleChoice,options:['357','537','573','735'],answer:'537'),
  Task(id:'cur_g3_n2',grade:3,topic:'Числа до 1000',question:'Сколько сотен в числе 847?',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g3_n3',grade:3,topic:'Числа до 1000',question:'Следующее число после 999 — это',type:TaskType.textInput,answer:'1000'),
  Task(id:'cur_g3_n4',grade:3,topic:'Числа до 1000',question:'624 = 600 + 20 + ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g3_n5',grade:3,topic:'Числа до 1000',question:'Сколько десятков в числе 730?',type:TaskType.textInput,answer:'73'),
  Task(id:'cur_g3_n6',grade:3,topic:'Числа до 1000',question:'Число на 100 больше чем 450 — это',type:TaskType.textInput,answer:'550'),
  Task(id:'cur_g3_n7',grade:3,topic:'Числа до 1000',question:'4 сотни и 6 единиц — это число',type:TaskType.textInput,answer:'406'),
  Task(id:'cur_g3_n8',grade:3,topic:'Числа до 1000',question:'Сколько единиц в числе 583?',type:TaskType.textInput,answer:'3'),

  // --- Сложение до 1000 ---
  Task(id:'cur_g3_ad1',grade:3,topic:'Сложение до 1000',question:'345 + 212 = ?',type:TaskType.textInput,answer:'557'),
  Task(id:'cur_g3_ad2',grade:3,topic:'Сложение до 1000',question:'476 + 324 = ?',type:TaskType.textInput,answer:'800'),
  Task(id:'cur_g3_ad3',grade:3,topic:'Сложение до 1000',question:'583 + 147 = ?',type:TaskType.textInput,answer:'730'),
  Task(id:'cur_g3_ad4',grade:3,topic:'Сложение до 1000',question:'264 + 389 = ?',type:TaskType.textInput,answer:'653'),
  Task(id:'cur_g3_ad5',grade:3,topic:'Сложение до 1000',question:'705 + 196 = ?',type:TaskType.textInput,answer:'901'),
  Task(id:'cur_g3_ad6',grade:3,topic:'Сложение до 1000',question:'418 + 275 = ?',type:TaskType.textInput,answer:'693'),
  Task(id:'cur_g3_ad7',grade:3,topic:'Сложение до 1000',question:'639 + 261 = ?',type:TaskType.textInput,answer:'900'),
  Task(id:'cur_g3_ad8',grade:3,topic:'Сложение до 1000',question:'158 + 473 = ?',type:TaskType.textInput,answer:'631'),

  // --- Умножение на однозначное ---
  Task(id:'cur_g3_mu1',grade:3,topic:'Умножение на однозначное',question:'124 × 3 = ?',type:TaskType.textInput,answer:'372'),
  Task(id:'cur_g3_mu2',grade:3,topic:'Умножение на однозначное',question:'215 × 4 = ?',type:TaskType.textInput,answer:'860'),
  Task(id:'cur_g3_mu3',grade:3,topic:'Умножение на однозначное',question:'143 × 6 = ?',type:TaskType.textInput,answer:'858'),
  Task(id:'cur_g3_mu4',grade:3,topic:'Умножение на однозначное',question:'231 × 5 = ?',type:TaskType.textInput,answer:'1155'),
  Task(id:'cur_g3_mu5',grade:3,topic:'Умножение на однозначное',question:'302 × 7 = ?',type:TaskType.textInput,answer:'2114'),
  Task(id:'cur_g3_mu6',grade:3,topic:'Умножение на однозначное',question:'412 × 8 = ?',type:TaskType.textInput,answer:'3296'),
  Task(id:'cur_g3_mu7',grade:3,topic:'Умножение на однозначное',question:'123 × 9 = ?',type:TaskType.textInput,answer:'1107'),
  Task(id:'cur_g3_mu8',grade:3,topic:'Умножение на однозначное',question:'211 × 6 = ?',type:TaskType.textInput,answer:'1266'),

  // --- Деление на однозначное ---
  Task(id:'cur_g3_dv1',grade:3,topic:'Деление на однозначное',question:'126 ÷ 3 = ?',type:TaskType.textInput,answer:'42'),
  Task(id:'cur_g3_dv2',grade:3,topic:'Деление на однозначное',question:'248 ÷ 4 = ?',type:TaskType.textInput,answer:'62'),
  Task(id:'cur_g3_dv3',grade:3,topic:'Деление на однозначное',question:'315 ÷ 5 = ?',type:TaskType.textInput,answer:'63'),
  Task(id:'cur_g3_dv4',grade:3,topic:'Деление на однозначное',question:'486 ÷ 6 = ?',type:TaskType.textInput,answer:'81'),
  Task(id:'cur_g3_dv5',grade:3,topic:'Деление на однозначное',question:'392 ÷ 7 = ?',type:TaskType.textInput,answer:'56'),
  Task(id:'cur_g3_dv6',grade:3,topic:'Деление на однозначное',question:'640 ÷ 8 = ?',type:TaskType.textInput,answer:'80'),
  Task(id:'cur_g3_dv7',grade:3,topic:'Деление на однозначное',question:'567 ÷ 9 = ?',type:TaskType.textInput,answer:'63'),
  Task(id:'cur_g3_dv8',grade:3,topic:'Деление на однозначное',question:'432 ÷ 6 = ?',type:TaskType.textInput,answer:'72'),

  // --- Единицы времени ---
  Task(id:'cur_g3_t1',grade:3,topic:'Единицы времени',question:'Сколько минут в 1 часе?',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g3_t2',grade:3,topic:'Единицы времени',question:'Сколько секунд в 1 минуте?',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g3_t3',grade:3,topic:'Единицы времени',question:'Сколько часов в сутках?',type:TaskType.textInput,answer:'24'),
  Task(id:'cur_g3_t4',grade:3,topic:'Единицы времени',question:'Сколько дней в году (не високосном)?',type:TaskType.textInput,answer:'365'),
  Task(id:'cur_g3_t5',grade:3,topic:'Единицы времени',question:'2 часа = ? минут',type:TaskType.textInput,answer:'120'),
  Task(id:'cur_g3_t6',grade:3,topic:'Единицы времени',question:'3 минуты = ? секунд',type:TaskType.textInput,answer:'180'),
  Task(id:'cur_g3_t7',grade:3,topic:'Единицы времени',question:'Сколько месяцев в году?',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g3_t8',grade:3,topic:'Единицы времени',question:'1,5 часа = ? минут',type:TaskType.textInput,answer:'90'),

  // --- Доли ---
  Task(id:'cur_g3_dl1',grade:3,topic:'Доли',question:'1/2 от числа 10 = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g3_dl2',grade:3,topic:'Доли',question:'1/3 от числа 12 = ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g3_dl3',grade:3,topic:'Доли',question:'1/4 от числа 20 = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g3_dl4',grade:3,topic:'Доли',question:'1/5 от числа 25 = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g3_dl5',grade:3,topic:'Доли',question:'2/3 от числа 9 = ?',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g3_dl6',grade:3,topic:'Доли',question:'3/4 от числа 16 = ?',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g3_dl7',grade:3,topic:'Доли',question:'1/2 от числа 18 = ?',type:TaskType.textInput,answer:'9'),
  Task(id:'cur_g3_dl8',grade:3,topic:'Доли',question:'1/3 от числа 21 = ?',type:TaskType.textInput,answer:'7'),

  // ==================== КЛАСС 4 ====================

  // --- Умножение многозначных ---
  Task(id:'cur_g4_mb1',grade:4,topic:'Умножение многозначных',question:'123 × 11 = ?',type:TaskType.textInput,answer:'1353'),
  Task(id:'cur_g4_mb2',grade:4,topic:'Умножение многозначных',question:'245 × 12 = ?',type:TaskType.textInput,answer:'2940'),
  Task(id:'cur_g4_mb3',grade:4,topic:'Умножение многозначных',question:'318 × 21 = ?',type:TaskType.textInput,answer:'6678'),
  Task(id:'cur_g4_mb4',grade:4,topic:'Умножение многозначных',question:'412 × 25 = ?',type:TaskType.textInput,answer:'10300'),
  Task(id:'cur_g4_mb5',grade:4,topic:'Умножение многозначных',question:'156 × 14 = ?',type:TaskType.textInput,answer:'2184'),
  Task(id:'cur_g4_mb6',grade:4,topic:'Умножение многозначных',question:'234 × 32 = ?',type:TaskType.textInput,answer:'7488'),
  Task(id:'cur_g4_mb7',grade:4,topic:'Умножение многозначных',question:'275 × 16 = ?',type:TaskType.textInput,answer:'4400'),
  Task(id:'cur_g4_mb8',grade:4,topic:'Умножение многозначных',question:'321 × 45 = ?',type:TaskType.textInput,answer:'14445'),

  // --- Деление многозначных ---
  Task(id:'cur_g4_db1',grade:4,topic:'Деление многозначных',question:'840 ÷ 12 = ?',type:TaskType.textInput,answer:'70'),
  Task(id:'cur_g4_db2',grade:4,topic:'Деление многозначных',question:'672 ÷ 14 = ?',type:TaskType.textInput,answer:'48'),
  Task(id:'cur_g4_db3',grade:4,topic:'Деление многозначных',question:'855 ÷ 15 = ?',type:TaskType.textInput,answer:'57'),
  Task(id:'cur_g4_db4',grade:4,topic:'Деление многозначных',question:'930 ÷ 30 = ?',type:TaskType.textInput,answer:'31'),
  Task(id:'cur_g4_db5',grade:4,topic:'Деление многозначных',question:'1144 ÷ 22 = ?',type:TaskType.textInput,answer:'52'),
  Task(id:'cur_g4_db6',grade:4,topic:'Деление многозначных',question:'1512 ÷ 18 = ?',type:TaskType.textInput,answer:'84'),
  Task(id:'cur_g4_db7',grade:4,topic:'Деление многозначных',question:'2100 ÷ 25 = ?',type:TaskType.textInput,answer:'84'),
  Task(id:'cur_g4_db8',grade:4,topic:'Деление многозначных',question:'3276 ÷ 42 = ?',type:TaskType.textInput,answer:'78'),

  // --- Единицы площади ---
  Task(id:'cur_g4_ar1',grade:4,topic:'Единицы площади',question:'1 м² = ? дм²',type:TaskType.textInput,answer:'100'),
  Task(id:'cur_g4_ar2',grade:4,topic:'Единицы площади',question:'1 дм² = ? см²',type:TaskType.textInput,answer:'100'),
  Task(id:'cur_g4_ar3',grade:4,topic:'Единицы площади',question:'2 м² = ? дм²',type:TaskType.textInput,answer:'200'),
  Task(id:'cur_g4_ar4',grade:4,topic:'Единицы площади',question:'3 дм² = ? см²',type:TaskType.textInput,answer:'300'),
  Task(id:'cur_g4_ar5',grade:4,topic:'Единицы площади',question:'1 км² = ? м²',type:TaskType.multipleChoice,options:['100','10000','100000','1000000'],answer:'1000000'),
  Task(id:'cur_g4_ar6',grade:4,topic:'Единицы площади',question:'5 м² = ? дм²',type:TaskType.textInput,answer:'500'),
  Task(id:'cur_g4_ar7',grade:4,topic:'Единицы площади',question:'1 а = ? м²',type:TaskType.multipleChoice,options:['10','100','1000','10000'],answer:'100'),
  Task(id:'cur_g4_ar8',grade:4,topic:'Единицы площади',question:'1 га = ? а',type:TaskType.textInput,answer:'100'),

  // --- Объём ---
  Task(id:'cur_g4_vl1',grade:4,topic:'Объём',question:'Объём куба со стороной 3 см = ?',type:TaskType.textInput,answer:'27'),
  Task(id:'cur_g4_vl2',grade:4,topic:'Объём',question:'Прямоугольный параллелепипед 4×3×2. V = ?',type:TaskType.textInput,answer:'24'),
  Task(id:'cur_g4_vl3',grade:4,topic:'Объём',question:'Ящик: 5 дм × 4 дм × 3 дм. V = ?',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g4_vl4',grade:4,topic:'Объём',question:'Объём куба со стороной 2 = ?',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g4_vl5',grade:4,topic:'Объём',question:'Прямоугольный параллелепипед 6×5×4. V = ?',type:TaskType.textInput,answer:'120'),
  Task(id:'cur_g4_vl6',grade:4,topic:'Объём',question:'Объём куба со стороной 5 = ?',type:TaskType.textInput,answer:'125'),
  Task(id:'cur_g4_vl7',grade:4,topic:'Объём',question:'Параллелепипед 10×3×2. V = ?',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g4_vl8',grade:4,topic:'Объём',question:'Объём куба со стороной 4 = ?',type:TaskType.textInput,answer:'64'),

  // ==================== КЛАСС 5 ====================

  // --- Признаки делимости ---
  Task(id:'cur_g5_pd1',grade:5,topic:'Признаки делимости',question:'Делится ли число 135 на 5?',type:TaskType.multipleChoice,options:['Да','Нет','Только с остатком','Нельзя определить'],answer:'Да'),
  Task(id:'cur_g5_pd2',grade:5,topic:'Признаки делимости',question:'На какое из чисел делится 72?',type:TaskType.multipleChoice,options:['7','9','11','13'],answer:'9'),
  Task(id:'cur_g5_pd3',grade:5,topic:'Признаки делимости',question:'Делится ли 246 на 3? (Сумма цифр: 2+4+6=12)',type:TaskType.multipleChoice,options:['Да','Нет','Не всегда','Только с остатком'],answer:'Да'),
  Task(id:'cur_g5_pd4',grade:5,topic:'Признаки делимости',question:'Какое число делится и на 2, и на 3?',type:TaskType.multipleChoice,options:['34','45','36','55'],answer:'36'),
  Task(id:'cur_g5_pd5',grade:5,topic:'Признаки делимости',question:'Сумма цифр числа 567 = ?',type:TaskType.textInput,answer:'18'),
  Task(id:'cur_g5_pd6',grade:5,topic:'Признаки делимости',question:'Делится ли 1000 на 8?',type:TaskType.multipleChoice,options:['Да','Нет','Только с остатком','Не определить'],answer:'Да'),
  Task(id:'cur_g5_pd7',grade:5,topic:'Признаки делимости',question:'Какое из чисел делится на 9?',type:TaskType.multipleChoice,options:['45','47','49','53'],answer:'45'),
  Task(id:'cur_g5_pd8',grade:5,topic:'Признаки делимости',question:'Делится ли 84 на 4? (Последние 2 цифры: 84)',type:TaskType.multipleChoice,options:['Да','Нет','Только с остатком','Не определить'],answer:'Да'),

  // --- НОД и НОК ---
  Task(id:'cur_g5_gn1',grade:5,topic:'НОД и НОК',question:'НОД(12, 18) = ?',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g5_gn2',grade:5,topic:'НОД и НОК',question:'НОД(15, 25) = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g5_gn3',grade:5,topic:'НОД и НОК',question:'НОК(4, 6) = ?',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g5_gn4',grade:5,topic:'НОД и НОК',question:'НОК(3, 5) = ?',type:TaskType.textInput,answer:'15'),
  Task(id:'cur_g5_gn5',grade:5,topic:'НОД и НОК',question:'НОД(24, 36) = ?',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g5_gn6',grade:5,topic:'НОД и НОК',question:'НОК(6, 9) = ?',type:TaskType.textInput,answer:'18'),
  Task(id:'cur_g5_gn7',grade:5,topic:'НОД и НОК',question:'НОД(16, 24) = ?',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g5_gn8',grade:5,topic:'НОД и НОК',question:'НОК(8, 12) = ?',type:TaskType.textInput,answer:'24'),

  // --- Степень числа ---
  Task(id:'cur_g5_pw1',grade:5,topic:'Степень числа',question:'2⁵ = ?',type:TaskType.textInput,answer:'32'),
  Task(id:'cur_g5_pw2',grade:5,topic:'Степень числа',question:'3³ = ?',type:TaskType.textInput,answer:'27'),
  Task(id:'cur_g5_pw3',grade:5,topic:'Степень числа',question:'4² = ?',type:TaskType.textInput,answer:'16'),
  Task(id:'cur_g5_pw4',grade:5,topic:'Степень числа',question:'2⁶ = ?',type:TaskType.textInput,answer:'64'),
  Task(id:'cur_g5_pw5',grade:5,topic:'Степень числа',question:'5³ = ?',type:TaskType.textInput,answer:'125'),
  Task(id:'cur_g5_pw6',grade:5,topic:'Степень числа',question:'10³ = ?',type:TaskType.textInput,answer:'1000'),
  Task(id:'cur_g5_pw7',grade:5,topic:'Степень числа',question:'2⁸ = ?',type:TaskType.textInput,answer:'256'),
  Task(id:'cur_g5_pw8',grade:5,topic:'Степень числа',question:'3⁴ = ?',type:TaskType.textInput,answer:'81'),

  // --- Десятичные дроби ---
  Task(id:'cur_g5_dc1',grade:5,topic:'Десятичные дроби',question:'0,3 + 0,5 = ?',type:TaskType.textInput,answer:'0.8'),
  Task(id:'cur_g5_dc2',grade:5,topic:'Десятичные дроби',question:'1,2 + 0,8 = ?',type:TaskType.textInput,answer:'2'),
  Task(id:'cur_g5_dc3',grade:5,topic:'Десятичные дроби',question:'3,7 - 1,4 = ?',type:TaskType.textInput,answer:'2.3'),
  Task(id:'cur_g5_dc4',grade:5,topic:'Десятичные дроби',question:'2,5 × 4 = ?',type:TaskType.textInput,answer:'10'),
  Task(id:'cur_g5_dc5',grade:5,topic:'Десятичные дроби',question:'1,5 + 2,7 = ?',type:TaskType.textInput,answer:'4.2'),
  Task(id:'cur_g5_dc6',grade:5,topic:'Десятичные дроби',question:'5,6 - 2,3 = ?',type:TaskType.textInput,answer:'3.3'),
  Task(id:'cur_g5_dc7',grade:5,topic:'Десятичные дроби',question:'0,6 × 5 = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g5_dc8',grade:5,topic:'Десятичные дроби',question:'4,8 ÷ 4 = ?',type:TaskType.textInput,answer:'1.2'),

  // --- Среднее арифметическое ---
  Task(id:'cur_g5_av1',grade:5,topic:'Среднее арифметическое',question:'Среднее арифметическое чисел 4 и 8 = ?',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g5_av2',grade:5,topic:'Среднее арифметическое',question:'Среднее 3, 5, 7 = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g5_av3',grade:5,topic:'Среднее арифметическое',question:'Среднее 10, 20, 30 = ?',type:TaskType.textInput,answer:'20'),
  Task(id:'cur_g5_av4',grade:5,topic:'Среднее арифметическое',question:'Среднее 2, 6, 4, 8 = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g5_av5',grade:5,topic:'Среднее арифметическое',question:'Оценки: 4, 5, 4, 3. Среднее = ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g5_av6',grade:5,topic:'Среднее арифметическое',question:'Среднее чисел 12 и 20 = ?',type:TaskType.textInput,answer:'16'),
  Task(id:'cur_g5_av7',grade:5,topic:'Среднее арифметическое',question:'Среднее 1, 2, 3, 4, 5 = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g5_av8',grade:5,topic:'Среднее арифметическое',question:'Среднее 6, 8, 10, 12 = ?',type:TaskType.textInput,answer:'9'),

  // --- Объём параллелепипеда ---
  Task(id:'cur_g5_vp1',grade:5,topic:'Объём параллелепипеда',question:'V = д×ш×в. Д=5, Ш=4, В=3. V = ?',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g5_vp2',grade:5,topic:'Объём параллелепипеда',question:'Объём куба со стороной 6 = ?',type:TaskType.textInput,answer:'216'),
  Task(id:'cur_g5_vp3',grade:5,topic:'Объём параллелепипеда',question:'V параллелепипеда: 2×3×4 = ?',type:TaskType.textInput,answer:'24'),
  Task(id:'cur_g5_vp4',grade:5,topic:'Объём параллелепипеда',question:'Бассейн: 10×5×2 м. V = ?',type:TaskType.textInput,answer:'100'),
  Task(id:'cur_g5_vp5',grade:5,topic:'Объём параллелепипеда',question:'V параллелепипеда: 7×3×2 = ?',type:TaskType.textInput,answer:'42'),
  Task(id:'cur_g5_vp6',grade:5,topic:'Объём параллелепипеда',question:'Куб с ребром 4. V = ?',type:TaskType.textInput,answer:'64'),
  Task(id:'cur_g5_vp7',grade:5,topic:'Объём параллелепипеда',question:'Коробка: 8×6×5. V = ?',type:TaskType.textInput,answer:'240'),
  Task(id:'cur_g5_vp8',grade:5,topic:'Объём параллелепипеда',question:'V параллелепипеда: 3×3×10 = ?',type:TaskType.textInput,answer:'90'),

  // ==================== КЛАСС 6 ====================

  // --- Смешанные числа ---
  Task(id:'cur_g6_mx1',grade:6,topic:'Смешанные числа',question:'2½ = ? (в виде десятичной дроби)',type:TaskType.textInput,answer:'2.5'),
  Task(id:'cur_g6_mx2',grade:6,topic:'Смешанные числа',question:'Перевести 2⅓ в неправильную дробь',type:TaskType.multipleChoice,options:['5/3','7/3','8/3','6/3'],answer:'7/3'),
  Task(id:'cur_g6_mx3',grade:6,topic:'Смешанные числа',question:'1¾ + 1¼ = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g6_mx4',grade:6,topic:'Смешанные числа',question:'3½ - 1½ = ?',type:TaskType.textInput,answer:'2'),
  Task(id:'cur_g6_mx5',grade:6,topic:'Смешанные числа',question:'2⅔ + 1⅓ = ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g6_mx6',grade:6,topic:'Смешанные числа',question:'4½ × 2 = ?',type:TaskType.textInput,answer:'9'),
  Task(id:'cur_g6_mx7',grade:6,topic:'Смешанные числа',question:'3¾ - 1¼ = ?',type:TaskType.textInput,answer:'2.5'),
  Task(id:'cur_g6_mx8',grade:6,topic:'Смешанные числа',question:'2⅓ + ⅔ = ?',type:TaskType.textInput,answer:'3'),

  // --- Отношения ---
  Task(id:'cur_g6_rt1',grade:6,topic:'Отношения',question:'Отношение числа 15 к числу 3 = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g6_rt2',grade:6,topic:'Отношения',question:'Отношение 4 к 12 в виде дроби',type:TaskType.multipleChoice,options:['1/2','1/3','1/4','1/6'],answer:'1/3'),
  Task(id:'cur_g6_rt3',grade:6,topic:'Отношения',question:'Отношение 6 к 9 в виде дроби',type:TaskType.multipleChoice,options:['2/3','3/4','1/2','3/5'],answer:'2/3'),
  Task(id:'cur_g6_rt4',grade:6,topic:'Отношения',question:'В классе 12 мальчиков и 18 девочек. Отношение мальчиков к девочкам',type:TaskType.multipleChoice,options:['1/2','2/3','3/4','3/5'],answer:'2/3'),
  Task(id:'cur_g6_rt5',grade:6,topic:'Отношения',question:'Скорость велосипеда 18 км/ч, пешехода 6 км/ч. Отношение = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g6_rt6',grade:6,topic:'Отношения',question:'Длина 20 см, ширина 5 см. Отношение длины к ширине = ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g6_rt7',grade:6,topic:'Отношения',question:'Разделить 36 в отношении 1:3. Меньшая часть = ?',type:TaskType.textInput,answer:'9'),
  Task(id:'cur_g6_rt8',grade:6,topic:'Отношения',question:'Разделить 36 в отношении 1:3. Большая часть = ?',type:TaskType.textInput,answer:'27'),

  // --- Масштаб ---
  Task(id:'cur_g6_sc1',grade:6,topic:'Масштаб',question:'Масштаб 1:1000. На карте 5 см → реальное расстояние в м = ?',type:TaskType.textInput,answer:'50'),
  Task(id:'cur_g6_sc2',grade:6,topic:'Масштаб',question:'Масштаб 1:100000. На карте 3 см → реальное расстояние в км = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g6_sc3',grade:6,topic:'Масштаб',question:'Масштаб 1:200. На карте 4 см → реальная длина в м = ?',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g6_sc4',grade:6,topic:'Масштаб',question:'Масштаб 1:50000. Расстояние 2 км = на карте ? см',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g6_sc5',grade:6,topic:'Масштаб',question:'Масштаб 1:10000. На карте 6 см → расстояние в м = ?',type:TaskType.textInput,answer:'600'),
  Task(id:'cur_g6_sc6',grade:6,topic:'Масштаб',question:'Масштаб 1:500. Расстояние 10 м = на карте ? см',type:TaskType.textInput,answer:'2'),
  Task(id:'cur_g6_sc7',grade:6,topic:'Масштаб',question:'Масштаб 1:5000. На карте 15 см → расстояние в м = ?',type:TaskType.textInput,answer:'750'),
  Task(id:'cur_g6_sc8',grade:6,topic:'Масштаб',question:'Масштаб 1:25000. На карте 4 см → расстояние в м = ?',type:TaskType.textInput,answer:'1000'),

  // --- Абсолютная величина ---
  Task(id:'cur_g6_ab1',grade:6,topic:'Абсолютная величина',question:'|5| = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g6_ab2',grade:6,topic:'Абсолютная величина',question:'|-7| = ?',type:TaskType.textInput,answer:'7'),
  Task(id:'cur_g6_ab3',grade:6,topic:'Абсолютная величина',question:'|-3,5| = ?',type:TaskType.textInput,answer:'3.5'),
  Task(id:'cur_g6_ab4',grade:6,topic:'Абсолютная величина',question:'|0| = ?',type:TaskType.textInput,answer:'0'),
  Task(id:'cur_g6_ab5',grade:6,topic:'Абсолютная величина',question:'|-12| = ?',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g6_ab6',grade:6,topic:'Абсолютная величина',question:'Верно ли: |-8| > |5|?',type:TaskType.multipleChoice,options:['Да','Нет','Не всегда','Нельзя сравнить'],answer:'Да'),
  Task(id:'cur_g6_ab7',grade:6,topic:'Абсолютная величина',question:'|-15| + |6| = ?',type:TaskType.textInput,answer:'21'),
  Task(id:'cur_g6_ab8',grade:6,topic:'Абсолютная величина',question:'|-4| × |-3| = ?',type:TaskType.textInput,answer:'12'),

  // --- Средние величины ---
  Task(id:'cur_g6_sv1',grade:6,topic:'Средние величины',question:'Температура 7 дней: 10,12,14,12,10,12,14. Средняя = ?',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g6_sv2',grade:6,topic:'Средние величины',question:'Результаты прыжков: 3.5, 4.0, 3.0, 3.5 м. Среднее = ?',type:TaskType.textInput,answer:'3.5'),
  Task(id:'cur_g6_sv3',grade:6,topic:'Средние величины',question:'5 учеников: 70, 80, 90, 60, 100 баллов. Среднее = ?',type:TaskType.textInput,answer:'80'),
  Task(id:'cur_g6_sv4',grade:6,topic:'Средние величины',question:'Четыре измерения: 2.2, 2.4, 2.6, 2.8. Среднее = ?',type:TaskType.textInput,answer:'2.5'),
  Task(id:'cur_g6_sv5',grade:6,topic:'Средние величины',question:'Ящики весят 15, 20, 25 кг. Средний вес = ?',type:TaskType.textInput,answer:'20'),
  Task(id:'cur_g6_sv6',grade:6,topic:'Средние величины',question:'Среднее 6 чисел равно 10. Их сумма = ?',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g6_sv7',grade:6,topic:'Средние величины',question:'Три числа: 5, x, 7. Среднее = 6. Найди x',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g6_sv8',grade:6,topic:'Средние величины',question:'Скорость 60 км/ч и 40 км/ч (по часу). Средняя скорость = ?',type:TaskType.textInput,answer:'50'),

  // --- Окружность и круг ---
  Task(id:'cur_g6_cr1',grade:6,topic:'Окружность и круг',question:'Радиус круга 5 см. Диаметр = ?',type:TaskType.textInput,answer:'10'),
  Task(id:'cur_g6_cr2',grade:6,topic:'Окружность и круг',question:'Диаметр окружности 14 см. Радиус = ?',type:TaskType.textInput,answer:'7'),
  Task(id:'cur_g6_cr3',grade:6,topic:'Окружность и круг',question:'Число π ≈ ?',type:TaskType.multipleChoice,options:['2.14','3.14','4.14','3.41'],answer:'3.14'),
  Task(id:'cur_g6_cr4',grade:6,topic:'Окружность и круг',question:'C = 2πr. r=5, π≈3.14. C ≈ ?',type:TaskType.multipleChoice,options:['15.7','31.4','62.8','78.5'],answer:'31.4'),
  Task(id:'cur_g6_cr5',grade:6,topic:'Окружность и круг',question:'S = πr². r=10, π≈3.14. S ≈ ?',type:TaskType.multipleChoice,options:['31.4','62.8','314','628'],answer:'314'),
  Task(id:'cur_g6_cr6',grade:6,topic:'Окружность и круг',question:'Если радиус круга вдвое больше, площадь больше в ? раз',type:TaskType.multipleChoice,options:['2','3','4','8'],answer:'4'),
  Task(id:'cur_g6_cr7',grade:6,topic:'Окружность и круг',question:'Отрезок от центра до точки на окружности называется',type:TaskType.multipleChoice,options:['диаметр','радиус','хорда','дуга'],answer:'радиус'),
  Task(id:'cur_g6_cr8',grade:6,topic:'Окружность и круг',question:'Хорда — это отрезок, соединяющий две точки',type:TaskType.multipleChoice,options:['центра','окружности','радиуса','дуги'],answer:'окружности'),


  // ==================== КЛАСС 7 ====================

  // --- Тождественные преобразования ---
  Task(id:'cur_g7_id1',grade:7,topic:'Тождественные преобразования',question:'(a + b)² = ?',type:TaskType.multipleChoice,options:['a²+b²','a²+2ab+b²','a²-2ab+b²','2a+2b'],answer:'a²+2ab+b²'),
  Task(id:'cur_g7_id2',grade:7,topic:'Тождественные преобразования',question:'(a - b)² = ?',type:TaskType.multipleChoice,options:['a²+b²','a²+2ab+b²','a²-2ab+b²','a²-b²'],answer:'a²-2ab+b²'),
  Task(id:'cur_g7_id3',grade:7,topic:'Тождественные преобразования',question:'(a+b)(a-b) = ?',type:TaskType.multipleChoice,options:['a²-b²','a²+b²','a²+2ab-b²','a²-2ab-b²'],answer:'a²-b²'),
  Task(id:'cur_g7_id4',grade:7,topic:'Тождественные преобразования',question:'Раскрой: (x+3)² = ?',type:TaskType.multipleChoice,options:['x²+9','x²+6x+9','x²+3x+9','x²+6x+3'],answer:'x²+6x+9'),
  Task(id:'cur_g7_id5',grade:7,topic:'Тождественные преобразования',question:'Раскрой: (2x-1)² = ?',type:TaskType.multipleChoice,options:['4x²+1','4x²-4x+1','4x²-1','2x²-4x+1'],answer:'4x²-4x+1'),
  Task(id:'cur_g7_id6',grade:7,topic:'Тождественные преобразования',question:'(x+5)(x-5) = ?',type:TaskType.multipleChoice,options:['x²-25','x²+25','x²-5x+25','x²+5x-25'],answer:'x²-25'),
  Task(id:'cur_g7_id7',grade:7,topic:'Тождественные преобразования',question:'Разложи на множители: x²-9 = ?',type:TaskType.multipleChoice,options:['(x-3)²','(x+3)(x-3)','(x-9)(x+1)','(x+9)(x-1)'],answer:'(x+3)(x-3)'),
  Task(id:'cur_g7_id8',grade:7,topic:'Тождественные преобразования',question:'(3x+2)² - (3x-2)² = ?',type:TaskType.multipleChoice,options:['0','24x','9x²','4'],answer:'24x'),

  // --- Параллельные прямые ---
  Task(id:'cur_g7_pp1',grade:7,topic:'Параллельные прямые',question:'Накрест лежащие углы при параллельных прямых',type:TaskType.multipleChoice,options:['равны','смежны','вертикальны','дополнительны'],answer:'равны'),
  Task(id:'cur_g7_pp2',grade:7,topic:'Параллельные прямые',question:'Накрест лежащий угол к углу 70° при параллельных прямых = ?°',type:TaskType.textInput,answer:'70'),
  Task(id:'cur_g7_pp3',grade:7,topic:'Параллельные прямые',question:'Односторонние углы при параллельных прямых в сумме = ?°',type:TaskType.textInput,answer:'180'),
  Task(id:'cur_g7_pp4',grade:7,topic:'Параллельные прямые',question:'Один из односторонних углов = 110°. Другой = ?°',type:TaskType.textInput,answer:'70'),
  Task(id:'cur_g7_pp5',grade:7,topic:'Параллельные прямые',question:'Соответственный угол к углу 65° при параллельных прямых = ?°',type:TaskType.textInput,answer:'65'),
  Task(id:'cur_g7_pp6',grade:7,topic:'Параллельные прямые',question:'Угол при секущей = 40°. Соответственный угол = ?°',type:TaskType.textInput,answer:'40'),
  Task(id:'cur_g7_pp7',grade:7,topic:'Параллельные прямые',question:'Один из односторонних углов = 55°. Другой = ?°',type:TaskType.textInput,answer:'125'),
  Task(id:'cur_g7_pp8',grade:7,topic:'Параллельные прямые',question:'Накрест лежащие углы = 90°. Прямые параллельны?',type:TaskType.multipleChoice,options:['Да','Нет','Не обязательно','Только при условии'],answer:'Да'),

  // --- Углы треугольника ---
  Task(id:'cur_g7_at1',grade:7,topic:'Углы треугольника',question:'Сумма углов треугольника = ?°',type:TaskType.textInput,answer:'180'),
  Task(id:'cur_g7_at2',grade:7,topic:'Углы треугольника',question:'Два угла: 60° и 70°. Третий угол = ?°',type:TaskType.textInput,answer:'50'),
  Task(id:'cur_g7_at3',grade:7,topic:'Углы треугольника',question:'Каждый угол равностороннего треугольника = ?°',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g7_at4',grade:7,topic:'Углы треугольника',question:'Прямоугольный треугольник. Один острый угол = 35°. Другой = ?°',type:TaskType.textInput,answer:'55'),
  Task(id:'cur_g7_at5',grade:7,topic:'Углы треугольника',question:'Углы треугольника: 90° и 45°. Третий = ?°',type:TaskType.textInput,answer:'45'),
  Task(id:'cur_g7_at6',grade:7,topic:'Углы треугольника',question:'Внешний угол треугольника равен сумме двух ? углов',type:TaskType.multipleChoice,options:['смежных','вертикальных','внутренних несмежных','прилежащих'],answer:'внутренних несмежных'),
  Task(id:'cur_g7_at7',grade:7,topic:'Углы треугольника',question:'Внешний угол = 120°. Сумма двух несмежных внутренних = ?°',type:TaskType.textInput,answer:'120'),
  Task(id:'cur_g7_at8',grade:7,topic:'Углы треугольника',question:'В тупоугольном треугольнике один угол = 110°. Может ли один из острых = 30°?',type:TaskType.multipleChoice,options:['Да','Нет','Только если он прямоугольный','Нельзя определить'],answer:'Да'),

  // --- Линейные неравенства ---
  Task(id:'cur_g7_ln1',grade:7,topic:'Линейные неравенства',question:'x + 3 > 7. Решение: x > ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g7_ln2',grade:7,topic:'Линейные неравенства',question:'2x < 10. Решение: x < ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g7_ln3',grade:7,topic:'Линейные неравенства',question:'x - 5 ≥ 3. Решение: x ≥ ?',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g7_ln4',grade:7,topic:'Линейные неравенства',question:'3x > 12. Решение: x > ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g7_ln5',grade:7,topic:'Линейные неравенства',question:'-2x < 8. При делении на −2 знак меняется. x > ?',type:TaskType.textInput,answer:'-4'),
  Task(id:'cur_g7_ln6',grade:7,topic:'Линейные неравенства',question:'x + 7 ≤ 15. Решение: x ≤ ?',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g7_ln7',grade:7,topic:'Линейные неравенства',question:'4x - 3 > 9. Решение: x > ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g7_ln8',grade:7,topic:'Линейные неравенства',question:'5 - x > 2. Решение: x < ?',type:TaskType.textInput,answer:'3'),

  // --- Смежные и вертикальные углы ---
  Task(id:'cur_g7_sv1',grade:7,topic:'Смежные и вертикальные углы',question:'Смежные углы в сумме = ?°',type:TaskType.textInput,answer:'180'),
  Task(id:'cur_g7_sv2',grade:7,topic:'Смежные и вертикальные углы',question:'Один из смежных углов = 65°. Другой = ?°',type:TaskType.textInput,answer:'115'),
  Task(id:'cur_g7_sv3',grade:7,topic:'Смежные и вертикальные углы',question:'Вертикальные углы',type:TaskType.multipleChoice,options:['равны','смежны','дополняют до 180°','дополняют до 90°'],answer:'равны'),
  Task(id:'cur_g7_sv4',grade:7,topic:'Смежные и вертикальные углы',question:'Угол = 40°. Его вертикальный = ?°',type:TaskType.textInput,answer:'40'),
  Task(id:'cur_g7_sv5',grade:7,topic:'Смежные и вертикальные углы',question:'Угол = 135°. Его смежный = ?°',type:TaskType.textInput,answer:'45'),
  Task(id:'cur_g7_sv6',grade:7,topic:'Смежные и вертикальные углы',question:'При пересечении двух прямых пар вертикальных углов = ?',type:TaskType.textInput,answer:'2'),
  Task(id:'cur_g7_sv7',grade:7,topic:'Смежные и вертикальные углы',question:'Угол = 2x°, смежный = 4x°. Найди x',type:TaskType.textInput,answer:'30'),
  Task(id:'cur_g7_sv8',grade:7,topic:'Смежные и вертикальные углы',question:'Угол = 90°. Его смежный = ?°',type:TaskType.textInput,answer:'90'),

  // ==================== КЛАСС 8 ====================

  // --- Теорема Пифагора ---
  Task(id:'cur_g8_py1',grade:8,topic:'Теорема Пифагора',question:'Катеты 3 и 4. Гипотенуза = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g8_py2',grade:8,topic:'Теорема Пифагора',question:'Катеты 6 и 8. Гипотенуза = ?',type:TaskType.textInput,answer:'10'),
  Task(id:'cur_g8_py3',grade:8,topic:'Теорема Пифагора',question:'Гипотенуза = 13, один катет = 5. Другой катет = ?',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g8_py4',grade:8,topic:'Теорема Пифагора',question:'Катеты 5 и 12. Гипотенуза = ?',type:TaskType.textInput,answer:'13'),
  Task(id:'cur_g8_py5',grade:8,topic:'Теорема Пифагора',question:'Гипотенуза = 10, один катет = 6. Другой катет = ?',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g8_py6',grade:8,topic:'Теорема Пифагора',question:'Катеты 8 и 15. Гипотенуза = ?',type:TaskType.textInput,answer:'17'),
  Task(id:'cur_g8_py7',grade:8,topic:'Теорема Пифагора',question:'Гипотенуза = 25, один катет = 7. Другой катет = ?',type:TaskType.textInput,answer:'24'),
  Task(id:'cur_g8_py8',grade:8,topic:'Теорема Пифагора',question:'Катеты 9 и 12. Гипотенуза = ?',type:TaskType.textInput,answer:'15'),

  // --- Четырёхугольники ---
  Task(id:'cur_g8_qu1',grade:8,topic:'Четырёхугольники',question:'Сумма углов четырёхугольника = ?°',type:TaskType.textInput,answer:'360'),
  Task(id:'cur_g8_qu2',grade:8,topic:'Четырёхугольники',question:'У прямоугольника все углы = ?°',type:TaskType.textInput,answer:'90'),
  Task(id:'cur_g8_qu3',grade:8,topic:'Четырёхугольники',question:'Диагонали ромба',type:TaskType.multipleChoice,options:['равны','перпендикулярны','параллельны','не пересекаются'],answer:'перпендикулярны'),
  Task(id:'cur_g8_qu4',grade:8,topic:'Четырёхугольники',question:'Прямоугольник: стороны 6 и 9. Периметр = ?',type:TaskType.textInput,answer:'30'),
  Task(id:'cur_g8_qu5',grade:8,topic:'Четырёхугольники',question:'Ромб со стороной 7. Периметр = ?',type:TaskType.textInput,answer:'28'),
  Task(id:'cur_g8_qu6',grade:8,topic:'Четырёхугольники',question:'Параллелограмм: два угла = 70°. Два других = ?°',type:TaskType.textInput,answer:'110'),
  Task(id:'cur_g8_qu7',grade:8,topic:'Четырёхугольники',question:'Трапеция: основания 10 и 6, высота 4. Площадь = ?',type:TaskType.textInput,answer:'32'),
  Task(id:'cur_g8_qu8',grade:8,topic:'Четырёхугольники',question:'Параллелограмм: основание 8, высота 3. Площадь = ?',type:TaskType.textInput,answer:'24'),

  // --- Площади фигур ---
  Task(id:'cur_g8_ar1',grade:8,topic:'Площади фигур',question:'Треугольник: основание 10, высота 6. S = ?',type:TaskType.textInput,answer:'30'),
  Task(id:'cur_g8_ar2',grade:8,topic:'Площади фигур',question:'Параллелограмм: основание 8, высота 5. S = ?',type:TaskType.textInput,answer:'40'),
  Task(id:'cur_g8_ar3',grade:8,topic:'Площади фигур',question:'Трапеция: основания 12 и 8, высота 5. S = ?',type:TaskType.textInput,answer:'50'),
  Task(id:'cur_g8_ar4',grade:8,topic:'Площади фигур',question:'Ромб: диагонали 6 и 8. S = ?',type:TaskType.textInput,answer:'24'),
  Task(id:'cur_g8_ar5',grade:8,topic:'Площади фигур',question:'Прямоугольник: 7 × 9. S = ?',type:TaskType.textInput,answer:'63'),
  Task(id:'cur_g8_ar6',grade:8,topic:'Площади фигур',question:'Квадрат: сторона 11. S = ?',type:TaskType.textInput,answer:'121'),
  Task(id:'cur_g8_ar7',grade:8,topic:'Площади фигур',question:'Прямоугольный треугольник: катеты 3 и 4. S = ?',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g8_ar8',grade:8,topic:'Площади фигур',question:'Ромб: диагонали 10 и 12. S = ?',type:TaskType.textInput,answer:'60'),

  // --- Подобные треугольники ---
  Task(id:'cur_g8_si1',grade:8,topic:'Подобные треугольники',question:'Коэффициент подобия k=2. Отношение площадей = ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g8_si2',grade:8,topic:'Подобные треугольники',question:'Коэффициент подобия k=3. Отношение периметров = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g8_si3',grade:8,topic:'Подобные треугольники',question:'Треугольники подобны, k=2. Сторона меньшего = 5. Сторона большего = ?',type:TaskType.textInput,answer:'10'),
  Task(id:'cur_g8_si4',grade:8,topic:'Подобные треугольники',question:'Стороны одного: 3, 4, 5. Подобного при k=2: 6, 8, ?',type:TaskType.textInput,answer:'10'),
  Task(id:'cur_g8_si5',grade:8,topic:'Подобные треугольники',question:'Коэффициент подобия k=4. Отношение площадей = ?',type:TaskType.textInput,answer:'16'),
  Task(id:'cur_g8_si6',grade:8,topic:'Подобные треугольники',question:'k=1.5. Периметр меньшего = 20. Периметр большего = ?',type:TaskType.textInput,answer:'30'),
  Task(id:'cur_g8_si7',grade:8,topic:'Подобные треугольники',question:'k=0.5. Периметр большего = 24. Периметр меньшего = ?',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g8_si8',grade:8,topic:'Подобные треугольники',question:'Треугольники подобны, k=½. Сторона большего = 12. Сторона меньшего = ?',type:TaskType.textInput,answer:'6'),

  // --- Числовые неравенства ---
  Task(id:'cur_g8_ni1',grade:8,topic:'Числовые неравенства',question:'x² > 9. Решение: x > 3 или x < ?',type:TaskType.textInput,answer:'-3'),
  Task(id:'cur_g8_ni2',grade:8,topic:'Числовые неравенства',question:'x² < 25. Решение: -5 < x < ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g8_ni3',grade:8,topic:'Числовые неравенства',question:'|x| ≤ 5. Решение: -5 ≤ x ≤ ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g8_ni4',grade:8,topic:'Числовые неравенства',question:'|x| > 3. Решение: x > 3 или x < ?',type:TaskType.textInput,answer:'-3'),
  Task(id:'cur_g8_ni5',grade:8,topic:'Числовые неравенства',question:'(x-1)(x+3) < 0. Решение: -3 < x < ?',type:TaskType.textInput,answer:'1'),
  Task(id:'cur_g8_ni6',grade:8,topic:'Числовые неравенства',question:'|x - 2| < 5. Решение: -3 < x < ?',type:TaskType.textInput,answer:'7'),
  Task(id:'cur_g8_ni7',grade:8,topic:'Числовые неравенства',question:'x² - 4 ≥ 0. Одно из решений: x ≥ 2 или x ≤ ?',type:TaskType.textInput,answer:'-2'),
  Task(id:'cur_g8_ni8',grade:8,topic:'Числовые неравенства',question:'x(x-4) > 0. Решение: x > 4 или x < ?',type:TaskType.textInput,answer:'0'),

  // --- Вписанные углы ---
  Task(id:'cur_g8_vi1',grade:8,topic:'Вписанные углы',question:'Вписанный угол равен ? от центрального на ту же дугу',type:TaskType.multipleChoice,options:['половине','двойному','равен','в 3 раза меньше'],answer:'половине'),
  Task(id:'cur_g8_vi2',grade:8,topic:'Вписанные углы',question:'Центральный угол = 80°. Вписанный на ту же дугу = ?°',type:TaskType.textInput,answer:'40'),
  Task(id:'cur_g8_vi3',grade:8,topic:'Вписанные углы',question:'Вписанный угол = 45°. Центральный = ?°',type:TaskType.textInput,answer:'90'),
  Task(id:'cur_g8_vi4',grade:8,topic:'Вписанные углы',question:'Вписанный угол, опирающийся на диаметр = ?°',type:TaskType.textInput,answer:'90'),
  Task(id:'cur_g8_vi5',grade:8,topic:'Вписанные углы',question:'Два вписанных угла на одну дугу: один = 35°. Другой = ?°',type:TaskType.textInput,answer:'35'),
  Task(id:'cur_g8_vi6',grade:8,topic:'Вписанные углы',question:'Центральный угол = 150°. Вписанный = ?°',type:TaskType.textInput,answer:'75'),
  Task(id:'cur_g8_vi7',grade:8,topic:'Вписанные углы',question:'Вписанный угол = 60°. Центральный = ?°',type:TaskType.textInput,answer:'120'),
  Task(id:'cur_g8_vi8',grade:8,topic:'Вписанные углы',question:'Вписанный угол = 30°. Центральный = ?°',type:TaskType.textInput,answer:'60'),

  // ==================== КЛАСС 9 ====================

  // --- Функция y=ax² ---
  Task(id:'cur_g9_qa1',grade:9,topic:'Функция y=ax²',question:'y = x². При x = 3, y = ?',type:TaskType.textInput,answer:'9'),
  Task(id:'cur_g9_qa2',grade:9,topic:'Функция y=ax²',question:'Вершина параболы y = (x-2)²+1 находится в точке (2, ?)',type:TaskType.textInput,answer:'1'),
  Task(id:'cur_g9_qa3',grade:9,topic:'Функция y=ax²',question:'Парабола y = -x². Ветви направлены',type:TaskType.multipleChoice,options:['вверх','вниз','вправо','влево'],answer:'вниз'),
  Task(id:'cur_g9_qa4',grade:9,topic:'Функция y=ax²',question:'y = 2x². При x = -3, y = ?',type:TaskType.textInput,answer:'18'),
  Task(id:'cur_g9_qa5',grade:9,topic:'Функция y=ax²',question:'y = x² - 6x + 9 = (x - ?)². Корень вершины',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g9_qa6',grade:9,topic:'Функция y=ax²',question:'y = x² - 4. Нули функции: x = ±?',type:TaskType.textInput,answer:'2'),
  Task(id:'cur_g9_qa7',grade:9,topic:'Функция y=ax²',question:'При каком a парабола y=ax² направлена вверх?',type:TaskType.multipleChoice,options:['a = -2','a = -1','a = 0','a = 3'],answer:'a = 3'),
  Task(id:'cur_g9_qa8',grade:9,topic:'Функция y=ax²',question:'Ось симметрии параболы y = x² - 4x + 3: x = ?',type:TaskType.textInput,answer:'2'),

  // --- Метод интервалов ---
  Task(id:'cur_g9_mi1',grade:9,topic:'Метод интервалов',question:'(x-1)(x+2) > 0. Решение: x > 1 или x < ?',type:TaskType.textInput,answer:'-2'),
  Task(id:'cur_g9_mi2',grade:9,topic:'Метод интервалов',question:'(x+3)(x-5) < 0. Решение: -3 < x < ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g9_mi3',grade:9,topic:'Метод интервалов',question:'x(x-4) ≥ 0. Решение: x ≤ 0 или x ≥ ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g9_mi4',grade:9,topic:'Метод интервалов',question:'(x-2)(x-6) ≤ 0. Решение: 2 ≤ x ≤ ?',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g9_mi5',grade:9,topic:'Метод интервалов',question:'x²-9 > 0. Одно решение: x > 3 или x < ?',type:TaskType.textInput,answer:'-3'),
  Task(id:'cur_g9_mi6',grade:9,topic:'Метод интервалов',question:'(x+1)(x+4) > 0. Решение: x < -4 или x > ?',type:TaskType.textInput,answer:'-1'),
  Task(id:'cur_g9_mi7',grade:9,topic:'Метод интервалов',question:'x²-16 < 0. Решение: -4 < x < ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g9_mi8',grade:9,topic:'Метод интервалов',question:'(x-3)(x+7) = 0. Корни: 3 и ?',type:TaskType.textInput,answer:'-7'),

  // --- Степенная функция ---
  Task(id:'cur_g9_pf1',grade:9,topic:'Степенная функция',question:'f(x) = x³. f(2) = ?',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g9_pf2',grade:9,topic:'Степенная функция',question:'f(x) = x⁴. f(-2) = ?',type:TaskType.textInput,answer:'16'),
  Task(id:'cur_g9_pf3',grade:9,topic:'Степенная функция',question:'y = √x. y(9) = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g9_pf4',grade:9,topic:'Степенная функция',question:'y = x². y(-5) = ?',type:TaskType.textInput,answer:'25'),
  Task(id:'cur_g9_pf5',grade:9,topic:'Степенная функция',question:'f(x) = 1/x. f(4) = ?',type:TaskType.textInput,answer:'0.25'),
  Task(id:'cur_g9_pf6',grade:9,topic:'Степенная функция',question:'f(x) = x³. f(-3) = ?',type:TaskType.textInput,answer:'-27'),
  Task(id:'cur_g9_pf7',grade:9,topic:'Степенная функция',question:'y = x⁵. y(2) = ?',type:TaskType.textInput,answer:'32'),
  Task(id:'cur_g9_pf8',grade:9,topic:'Степенная функция',question:'Кубический корень из 27 = ?',type:TaskType.textInput,answer:'3'),

  // --- Элементы комбинаторики ---
  Task(id:'cur_g9_co1',grade:9,topic:'Элементы комбинаторики',question:'Сколько способов выбрать 2 из 5? C(5,2) = ?',type:TaskType.textInput,answer:'10'),
  Task(id:'cur_g9_co2',grade:9,topic:'Элементы комбинаторики',question:'Число перестановок: 4! = ?',type:TaskType.textInput,answer:'24'),
  Task(id:'cur_g9_co3',grade:9,topic:'Элементы комбинаторики',question:'C(6,2) = ?',type:TaskType.textInput,answer:'15'),
  Task(id:'cur_g9_co4',grade:9,topic:'Элементы комбинаторики',question:'P(3) = 3! = ?',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g9_co5',grade:9,topic:'Элементы комбинаторики',question:'Из 10 спортсменов выбирают 3. C(10,3) = ?',type:TaskType.textInput,answer:'120'),
  Task(id:'cur_g9_co6',grade:9,topic:'Элементы комбинаторики',question:'A(5,2) = 5×4 = ?',type:TaskType.textInput,answer:'20'),
  Task(id:'cur_g9_co7',grade:9,topic:'Элементы комбинаторики',question:'Двузначных чисел из 1,2,3 без повторений = ?',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g9_co8',grade:9,topic:'Элементы комбинаторики',question:'C(4,4) = ?',type:TaskType.textInput,answer:'1'),

  // --- Векторы ---
  Task(id:'cur_g9_ve1',grade:9,topic:'Векторы',question:'Вектор a = (3, 4). Длина |a| = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g9_ve2',grade:9,topic:'Векторы',question:'a = (1, 0), b = (0, 1). Скалярное произведение a·b = ?',type:TaskType.textInput,answer:'0'),
  Task(id:'cur_g9_ve3',grade:9,topic:'Векторы',question:'a = (3, 0). |a| = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g9_ve4',grade:9,topic:'Векторы',question:'a = (6, 8). |a| = ?',type:TaskType.textInput,answer:'10'),
  Task(id:'cur_g9_ve5',grade:9,topic:'Векторы',question:'a = (2, 3), b = (1, 1). Сумма a+b: x-координата = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g9_ve6',grade:9,topic:'Векторы',question:'Угол между a = (1,0) и b = (0,1): ?°',type:TaskType.textInput,answer:'90'),
  Task(id:'cur_g9_ve7',grade:9,topic:'Векторы',question:'a = (5, 12). |a| = ?',type:TaskType.textInput,answer:'13'),
  Task(id:'cur_g9_ve8',grade:9,topic:'Векторы',question:'a = (4, 3). a·a = 4²+3² = ?',type:TaskType.textInput,answer:'25'),

  // --- Правильные многоугольники ---
  Task(id:'cur_g9_pm1',grade:9,topic:'Правильные многоугольники',question:'Сумма углов правильного шестиугольника = ?°',type:TaskType.textInput,answer:'720'),
  Task(id:'cur_g9_pm2',grade:9,topic:'Правильные многоугольники',question:'Каждый угол правильного шестиугольника = ?°',type:TaskType.textInput,answer:'120'),
  Task(id:'cur_g9_pm3',grade:9,topic:'Правильные многоугольники',question:'Сумма углов правильного пятиугольника = ?°',type:TaskType.textInput,answer:'540'),
  Task(id:'cur_g9_pm4',grade:9,topic:'Правильные многоугольники',question:'Каждый угол правильного пятиугольника = ?°',type:TaskType.textInput,answer:'108'),
  Task(id:'cur_g9_pm5',grade:9,topic:'Правильные многоугольники',question:'Каждый угол правильного восьмиугольника = ?°',type:TaskType.textInput,answer:'135'),
  Task(id:'cur_g9_pm6',grade:9,topic:'Правильные многоугольники',question:'Сумма углов n-угольника = 180° × (n - ?)',type:TaskType.textInput,answer:'2'),
  Task(id:'cur_g9_pm7',grade:9,topic:'Правильные многоугольники',question:'Каждый угол правильного треугольника = ?°',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g9_pm8',grade:9,topic:'Правильные многоугольники',question:'Сумма углов правильного четырёхугольника = ?°',type:TaskType.textInput,answer:'360'),

  // ==================== КЛАСС 10 ====================

  // --- Тригонометрические уравнения ---
  Task(id:'cur_g10_te1',grade:10,topic:'Тригонометрические уравнения',question:'sin x° = 0.5. Главное решение: x° = ?',type:TaskType.textInput,answer:'30'),
  Task(id:'cur_g10_te2',grade:10,topic:'Тригонометрические уравнения',question:'cos x° = 0. Главное решение: x° = ?',type:TaskType.multipleChoice,options:['45','60','90','180'],answer:'90'),
  Task(id:'cur_g10_te3',grade:10,topic:'Тригонометрические уравнения',question:'sin 30° = ?',type:TaskType.multipleChoice,options:['0','0.5','1','-1'],answer:'0.5'),
  Task(id:'cur_g10_te4',grade:10,topic:'Тригонометрические уравнения',question:'cos 60° = ?',type:TaskType.textInput,answer:'0.5'),
  Task(id:'cur_g10_te5',grade:10,topic:'Тригонометрические уравнения',question:'tg 45° = ?',type:TaskType.textInput,answer:'1'),
  Task(id:'cur_g10_te6',grade:10,topic:'Тригонометрические уравнения',question:'sin 90° = ?',type:TaskType.textInput,answer:'1'),
  Task(id:'cur_g10_te7',grade:10,topic:'Тригонометрические уравнения',question:'cos 0° = ?',type:TaskType.textInput,answer:'1'),
  Task(id:'cur_g10_te8',grade:10,topic:'Тригонометрические уравнения',question:'tg 0° = ?',type:TaskType.textInput,answer:'0'),

  // --- Показательные уравнения ---
  Task(id:'cur_g10_pe1',grade:10,topic:'Показательные уравнения',question:'2ˣ = 8. x = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g10_pe2',grade:10,topic:'Показательные уравнения',question:'3ˣ = 27. x = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g10_pe3',grade:10,topic:'Показательные уравнения',question:'5ˣ = 125. x = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g10_pe4',grade:10,topic:'Показательные уравнения',question:'2ˣ = 1/4. x = ?',type:TaskType.textInput,answer:'-2'),
  Task(id:'cur_g10_pe5',grade:10,topic:'Показательные уравнения',question:'4ˣ = 64. x = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g10_pe6',grade:10,topic:'Показательные уравнения',question:'2^(2x) = 16. x = ?',type:TaskType.textInput,answer:'2'),
  Task(id:'cur_g10_pe7',grade:10,topic:'Показательные уравнения',question:'10ˣ = 1000. x = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g10_pe8',grade:10,topic:'Показательные уравнения',question:'3ˣ = 1. x = ?',type:TaskType.textInput,answer:'0'),

  // --- Логарифмические уравнения ---
  Task(id:'cur_g10_le1',grade:10,topic:'Логарифмические уравнения',question:'log₂(8) = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g10_le2',grade:10,topic:'Логарифмические уравнения',question:'log₃(27) = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g10_le3',grade:10,topic:'Логарифмические уравнения',question:'log₁₀(1000) = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g10_le4',grade:10,topic:'Логарифмические уравнения',question:'log₂(1) = ?',type:TaskType.textInput,answer:'0'),
  Task(id:'cur_g10_le5',grade:10,topic:'Логарифмические уравнения',question:'log₅(5) = ?',type:TaskType.textInput,answer:'1'),
  Task(id:'cur_g10_le6',grade:10,topic:'Логарифмические уравнения',question:'log₂(32) = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g10_le7',grade:10,topic:'Логарифмические уравнения',question:'log₃(81) = ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g10_le8',grade:10,topic:'Логарифмические уравнения',question:'log₄(64) = ?',type:TaskType.textInput,answer:'3'),

  // --- Параллельность в пространстве ---
  Task(id:'cur_g10_prl1',grade:10,topic:'Параллельность в пространстве',question:'Если AB ∥ CD и CD ∥ EF, то AB и EF:',type:TaskType.multipleChoice,options:['параллельны','перпендикулярны','скрещиваются','пересекаются'],answer:'параллельны'),
  Task(id:'cur_g10_prl2',grade:10,topic:'Параллельность в пространстве',question:'В кубе, сколько граней параллельны данной грани?',type:TaskType.textInput,answer:'1'),
  Task(id:'cur_g10_prl3',grade:10,topic:'Параллельность в пространстве',question:'Если плоскость α ∥ β, γ пересекает их, линии пересечения:',type:TaskType.multipleChoice,options:['параллельны','перпендикулярны','совпадают','скрещиваются'],answer:'параллельны'),
  Task(id:'cur_g10_prl4',grade:10,topic:'Параллельность в пространстве',question:'Прямая, параллельная плоскости, имеет с ней ? общих точек',type:TaskType.multipleChoice,options:['0','1','2','бесконечно'],answer:'0'),
  Task(id:'cur_g10_prl5',grade:10,topic:'Параллельность в пространстве',question:'В прямоугольном параллелепипеде пар параллельных граней = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g10_prl6',grade:10,topic:'Параллельность в пространстве',question:'Через точку вне плоскости можно провести ? плоскостей, параллельных данной',type:TaskType.multipleChoice,options:['0','1','2','бесконечно'],answer:'1'),
  Task(id:'cur_g10_prl7',grade:10,topic:'Параллельность в пространстве',question:'Если прямая и плоскость не имеют общих точек, то они:',type:TaskType.multipleChoice,options:['перпендикулярны','параллельны','пересекаются','скрещиваются'],answer:'параллельны'),
  Task(id:'cur_g10_prl8',grade:10,topic:'Параллельность в пространстве',question:'Скрещивающиеся прямые:',type:TaskType.multipleChoice,options:['лежат в одной плоскости','не лежат в одной плоскости и не пересекаются','пересекаются под 90°','параллельны'],answer:'не лежат в одной плоскости и не пересекаются'),

  // --- Перпендикулярность в пространстве ---
  Task(id:'cur_g10_prp1',grade:10,topic:'Перпендикулярность в пространстве',question:'Если прямая ⊥ плоскости, она ⊥ ? прямой в плоскости',type:TaskType.multipleChoice,options:['ни одной','одной','двум','любой'],answer:'любой'),
  Task(id:'cur_g10_prp2',grade:10,topic:'Перпендикулярность в пространстве',question:'Угол между перпендикулярной прямой и плоскостью = ?°',type:TaskType.textInput,answer:'90'),
  Task(id:'cur_g10_prp3',grade:10,topic:'Перпендикулярность в пространстве',question:'Высота пирамиды ⊥ основанию. Угол между ними = ?°',type:TaskType.textInput,answer:'90'),
  Task(id:'cur_g10_prp4',grade:10,topic:'Перпендикулярность в пространстве',question:'Двугранный угол между ⊥ плоскостями = ?°',type:TaskType.textInput,answer:'90'),
  Task(id:'cur_g10_prp5',grade:10,topic:'Перпендикулярность в пространстве',question:'Смежные грани прямоугольного параллелепипеда:',type:TaskType.multipleChoice,options:['параллельны','перпендикулярны','пересекаются под 45°','скрещиваются'],answer:'перпендикулярны'),
  Task(id:'cur_g10_prp6',grade:10,topic:'Перпендикулярность в пространстве',question:'Для ⊥ прямой к плоскости нужно ⊥ двум пересекающимся прямым в плоскости?',type:TaskType.multipleChoice,options:['Да','Нет','Только при условии','Зависит от угла'],answer:'Да'),
  Task(id:'cur_g10_prp7',grade:10,topic:'Перпендикулярность в пространстве',question:'Все прямые ⊥ данной плоскости:',type:TaskType.multipleChoice,options:['параллельны друг другу','перпендикулярны друг другу','скрещиваются','пересекаются'],answer:'параллельны друг другу'),
  Task(id:'cur_g10_prp8',grade:10,topic:'Перпендикулярность в пространстве',question:'Проекция наклонной на плоскость — это её',type:TaskType.multipleChoice,options:['высота','основание','тень','след'],answer:'след'),

  // --- Многогранники ---
  Task(id:'cur_g10_mg1',grade:10,topic:'Многогранники',question:'Куб имеет ? рёбер',type:TaskType.textInput,answer:'12'),
  Task(id:'cur_g10_mg2',grade:10,topic:'Многогранники',question:'Куб имеет ? вершин',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g10_mg3',grade:10,topic:'Многогранники',question:'Куб имеет ? граней',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g10_mg4',grade:10,topic:'Многогранники',question:'Тетраэдр имеет ? рёбер',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g10_mg5',grade:10,topic:'Многогранники',question:'Пирамида с квадратным основанием имеет ? рёбер',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g10_mg6',grade:10,topic:'Многогранники',question:'Формула Эйлера: В + Г − Р = ?',type:TaskType.textInput,answer:'2'),
  Task(id:'cur_g10_mg7',grade:10,topic:'Многогранники',question:'У правильного октаэдра ? граней',type:TaskType.textInput,answer:'8'),
  Task(id:'cur_g10_mg8',grade:10,topic:'Многогранники',question:'Призма с n-угольным основанием имеет ? граней',type:TaskType.multipleChoice,options:['n','n+1','n+2','2n'],answer:'n+2'),

  // --- Тригонометрические неравенства ---
  Task(id:'cur_g10_tn1',grade:10,topic:'Тригонометрические неравенства',question:'sin x° > 0. x° ∈ ?',type:TaskType.multipleChoice,options:['(0°; 90°)','(0°; 180°)','(180°; 360°)','(90°; 270°)'],answer:'(0°; 180°)'),
  Task(id:'cur_g10_tn2',grade:10,topic:'Тригонометрические неравенства',question:'cos x° > 0. x° ∈ ?',type:TaskType.multipleChoice,options:['(0°; 90°)','(-90°; 90°)','(0°; 270°)','(90°; 270°)'],answer:'(-90°; 90°)'),
  Task(id:'cur_g10_tn3',grade:10,topic:'Тригонометрические неравенства',question:'sin x° ≥ 1. x° = ?',type:TaskType.textInput,answer:'90'),
  Task(id:'cur_g10_tn4',grade:10,topic:'Тригонометрические неравенства',question:'cos x° ≤ -1. x° = ?',type:TaskType.textInput,answer:'180'),
  Task(id:'cur_g10_tn5',grade:10,topic:'Тригонометрические неравенства',question:'sin x° < 0. x° ∈ ?',type:TaskType.multipleChoice,options:['(0°; 180°)','(180°; 360°)','(90°; 270°)','(0°; 90°)'],answer:'(180°; 360°)'),
  Task(id:'cur_g10_tn6',grade:10,topic:'Тригонометрические неравенства',question:'tg x° > 0. x° в первой или ? четверти',type:TaskType.multipleChoice,options:['второй','третьей','четвёртой','нулевой'],answer:'третьей'),
  Task(id:'cur_g10_tn7',grade:10,topic:'Тригонометрические неравенства',question:'cos x° = 0. x° = ?° или x° = 270°',type:TaskType.textInput,answer:'90'),
  Task(id:'cur_g10_tn8',grade:10,topic:'Тригонометрические неравенства',question:'sin x° = -0.5. Один из углов (в градусах) = ?',type:TaskType.multipleChoice,options:['150','210','330','30'],answer:'210'),

  // ==================== КЛАСС 11 ====================

  // --- Применение производной ---
  Task(id:'cur_g11_pd1',grade:11,topic:'Применение производной',question:'f(x) = x². f\'(x) = ?',type:TaskType.multipleChoice,options:['2x','x²','2','1/x²'],answer:'2x'),
  Task(id:'cur_g11_pd2',grade:11,topic:'Применение производной',question:'f(x) = 3x³. f\'(x) = ?',type:TaskType.multipleChoice,options:['3x²','9x²','9x','x³'],answer:'9x²'),
  Task(id:'cur_g11_pd3',grade:11,topic:'Применение производной',question:'f(x) = x⁴. f\'(x) = ?',type:TaskType.multipleChoice,options:['4x³','4x','x³','4x⁴'],answer:'4x³'),
  Task(id:'cur_g11_pd4',grade:11,topic:'Применение производной',question:'f(x) = x² - 4x + 3. Точка экстремума: x = ?',type:TaskType.textInput,answer:'2'),
  Task(id:'cur_g11_pd5',grade:11,topic:'Применение производной',question:'f(x) = -x² + 6x. Максимум при x = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g11_pd6',grade:11,topic:'Применение производной',question:'f(x) = x³ - 3x. f\'(x) = 3x²-3 = 0. Критическая точка x = ?',type:TaskType.textInput,answer:'1'),
  Task(id:'cur_g11_pd7',grade:11,topic:'Применение производной',question:'f(x) = 5. f\'(x) = ?',type:TaskType.textInput,answer:'0'),
  Task(id:'cur_g11_pd8',grade:11,topic:'Применение производной',question:'f\'(x) = 0 при x = 2 — это точка',type:TaskType.multipleChoice,options:['минимума','максимума','перегиба','экстремума'],answer:'экстремума'),

  // --- Метод координат в пространстве ---
  Task(id:'cur_g11_kp1',grade:11,topic:'Метод координат в пространстве',question:'A(3, 4, 0). |OA| = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g11_kp2',grade:11,topic:'Метод координат в пространстве',question:'A(0, 0, 5). |OA| = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g11_kp3',grade:11,topic:'Метод координат в пространстве',question:'A(1, 2, 2). |OA| = √(1+4+4) = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g11_kp4',grade:11,topic:'Метод координат в пространстве',question:'A(6, 8, 0). |OA| = ?',type:TaskType.textInput,answer:'10'),
  Task(id:'cur_g11_kp5',grade:11,topic:'Метод координат в пространстве',question:'A(1,1,1), B(4,1,1). |AB| = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g11_kp6',grade:11,topic:'Метод координат в пространстве',question:'A(2,2,1), B(5,6,1). |AB| = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g11_kp7',grade:11,topic:'Метод координат в пространстве',question:'A(0,0,0), B(6,4,2). x-координата середины AB = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g11_kp8',grade:11,topic:'Метод координат в пространстве',question:'A(1,0,0), B(4,4,0). |AB| = ?',type:TaskType.textInput,answer:'5'),

  // --- Цилиндр и конус ---
  Task(id:'cur_g11_ck1',grade:11,topic:'Цилиндр и конус',question:'V цилиндра = πr²h. При r=5, h=4. V/π = ?',type:TaskType.textInput,answer:'100'),
  Task(id:'cur_g11_ck2',grade:11,topic:'Цилиндр и конус',question:'Боковая поверхность цилиндра: r=5, h=3. S_бок/π = 2rh = ?',type:TaskType.textInput,answer:'30'),
  Task(id:'cur_g11_ck3',grade:11,topic:'Цилиндр и конус',question:'Полная поверхность цилиндра: r=3, h=7. S_полн/π = 2r(r+h) = ?',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g11_ck4',grade:11,topic:'Цилиндр и конус',question:'V конуса = πr²h/3. r=6, h=7. V/π = ?',type:TaskType.textInput,answer:'84'),
  Task(id:'cur_g11_ck5',grade:11,topic:'Цилиндр и конус',question:'Высота конуса 8, образующая 10. Радиус основания = ?',type:TaskType.textInput,answer:'6'),
  Task(id:'cur_g11_ck6',grade:11,topic:'Цилиндр и конус',question:'Осевое сечение цилиндра — это',type:TaskType.multipleChoice,options:['круг','квадрат','прямоугольник','трапеция'],answer:'прямоугольник'),
  Task(id:'cur_g11_ck7',grade:11,topic:'Цилиндр и конус',question:'Осевое сечение конуса — это',type:TaskType.multipleChoice,options:['круг','треугольник','прямоугольник','трапеция'],answer:'треугольник'),
  Task(id:'cur_g11_ck8',grade:11,topic:'Цилиндр и конус',question:'V конуса = πr²h/3. r=3, h=4. V/π = ?',type:TaskType.textInput,answer:'12'),

  // --- Шар и сфера ---
  Task(id:'cur_g11_sh1',grade:11,topic:'Шар и сфера',question:'V шара = 4πr³/3. r=3. V/π = ?',type:TaskType.textInput,answer:'36'),
  Task(id:'cur_g11_sh2',grade:11,topic:'Шар и сфера',question:'S сферы = 4πr². r=5. S/π = ?',type:TaskType.textInput,answer:'100'),
  Task(id:'cur_g11_sh3',grade:11,topic:'Шар и сфера',question:'S сферы = 4πr². r=1. S/π = ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g11_sh4',grade:11,topic:'Шар и сфера',question:'V шара = 4πr³/3. r=6. V/π = ?',type:TaskType.textInput,answer:'288'),
  Task(id:'cur_g11_sh5',grade:11,topic:'Шар и сфера',question:'Диаметр шара = 10. Радиус = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g11_sh6',grade:11,topic:'Шар и сфера',question:'Большой круг сферы — сечение, проходящее через',type:TaskType.multipleChoice,options:['любую точку','центр','экватор','полюс'],answer:'центр'),
  Task(id:'cur_g11_sh7',grade:11,topic:'Шар и сфера',question:'S сферы = 4πr². r=2. S/π = ?',type:TaskType.textInput,answer:'16'),
  Task(id:'cur_g11_sh8',grade:11,topic:'Шар и сфера',question:'V шара = 4πr³/3. r=1. V/π = ?',type:TaskType.textInput,answer:'1.33'),

  // --- Объёмы тел ---
  Task(id:'cur_g11_ot1',grade:11,topic:'Объёмы тел',question:'V куба: a = 4. V = ?',type:TaskType.textInput,answer:'64'),
  Task(id:'cur_g11_ot2',grade:11,topic:'Объёмы тел',question:'V пирамиды = S·h/3. Осн. 6×6=36, h=5. V = ?',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g11_ot3',grade:11,topic:'Объёмы тел',question:'V прямоугольного параллелепипеда: 3×4×5 = ?',type:TaskType.textInput,answer:'60'),
  Task(id:'cur_g11_ot4',grade:11,topic:'Объёмы тел',question:'V конуса: r=3, h=7. V/π = ?',type:TaskType.textInput,answer:'21'),
  Task(id:'cur_g11_ot5',grade:11,topic:'Объёмы тел',question:'V шара: r=3. V/π = ?',type:TaskType.textInput,answer:'36'),
  Task(id:'cur_g11_ot6',grade:11,topic:'Объёмы тел',question:'V пирамиды: осн. треугольник 6×8/2=24, h=10. V = ?',type:TaskType.textInput,answer:'80'),
  Task(id:'cur_g11_ot7',grade:11,topic:'Объёмы тел',question:'V цилиндра: r=4, h=6. V/π = ?',type:TaskType.textInput,answer:'96'),
  Task(id:'cur_g11_ot8',grade:11,topic:'Объёмы тел',question:'V куба = a³. Формула объёма куба зависит от',type:TaskType.multipleChoice,options:['диагонали','ребра','площади грани','периметра'],answer:'ребра'),

  // --- Статистика ---
  Task(id:'cur_g11_st1',grade:11,topic:'Статистика',question:'Данные: 2, 4, 4, 6, 8. Мода = ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g11_st2',grade:11,topic:'Статистика',question:'Данные: 2, 4, 4, 6, 8. Медиана = ?',type:TaskType.textInput,answer:'4'),
  Task(id:'cur_g11_st3',grade:11,topic:'Статистика',question:'Данные: 2, 4, 4, 6, 8. Среднее = ?',type:TaskType.textInput,answer:'4.8'),
  Task(id:'cur_g11_st4',grade:11,topic:'Статистика',question:'Дисперсия = 9. Стандартное отклонение = ?',type:TaskType.textInput,answer:'3'),
  Task(id:'cur_g11_st5',grade:11,topic:'Статистика',question:'Данные: 1, 3, 5, 7, 9. Медиана = ?',type:TaskType.textInput,answer:'5'),
  Task(id:'cur_g11_st6',grade:11,topic:'Статистика',question:'Числа: 10, 12, 14, 16, 18. Среднее = ?',type:TaskType.textInput,answer:'14'),
  Task(id:'cur_g11_st7',grade:11,topic:'Статистика',question:'Данные: 3, 3, 3, 3. Стандартное отклонение = ?',type:TaskType.textInput,answer:'0'),
  Task(id:'cur_g11_st8',grade:11,topic:'Статистика',question:'Размах: данные 2, 7, 3, 9, 1. Размах = макс - мин = ?',type:TaskType.textInput,answer:'8'),

  // --- Исследование функции ---
  Task(id:'cur_g11_if1',grade:11,topic:'Исследование функции',question:'f(x) = x² - 4. f\'(x) = 2x. Нуль производной: x = ?',type:TaskType.textInput,answer:'0'),
  Task(id:'cur_g11_if2',grade:11,topic:'Исследование функции',question:'f(x) = x³ - 3x. Убывает при: f\'(x) < 0, то есть при -1 < x < ?',type:TaskType.textInput,answer:'1'),
  Task(id:'cur_g11_if3',grade:11,topic:'Исследование функции',question:'f(x) = -x². Функция имеет',type:TaskType.multipleChoice,options:['минимум','максимум','нет экстремума','два экстремума'],answer:'максимум'),
  Task(id:'cur_g11_if4',grade:11,topic:'Исследование функции',question:'f(x) = x². Функция возрастает при x > ?',type:TaskType.textInput,answer:'0'),
  Task(id:'cur_g11_if5',grade:11,topic:'Исследование функции',question:'f(x) = x⁴ - 8x². f\'(x) = 4x(x²-4). Критические точки: 0 и ±?',type:TaskType.textInput,answer:'2'),
  Task(id:'cur_g11_if6',grade:11,topic:'Исследование функции',question:'f(x) = eˣ. f\'(x) = ?',type:TaskType.multipleChoice,options:['eˣ','x·eˣ⁻¹','eˣ⁻¹','0'],answer:'eˣ'),
  Task(id:'cur_g11_if7',grade:11,topic:'Исследование функции',question:'f(x) = ln x. f\'(x) = ?',type:TaskType.multipleChoice,options:['ln x','1/x','1/ln x','x'],answer:'1/x'),
  Task(id:'cur_g11_if8',grade:11,topic:'Исследование функции',question:'f(x) = x³ имеет точку перегиба при x = ?',type:TaskType.textInput,answer:'0'),

];
