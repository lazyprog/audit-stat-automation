﻿Перем scr;
Перем Desktop;
Перем Doc;

Перем Sheets;
Перем Sheet0;
Перем Sheet1;
Перем Sheet2;
Перем Sheet3;

Перем BorderStyle;
Перем NumberFormat;

Перем ТабФормат;

&НаКлиенте
Процедура Кнопка1Нажатие(Команда)
	Счета="";
	
	ПараметрыФормы = Новый Структура("ТаблицаСчетов", Объект.ТаблицаСчетов);
	
	ТаблицаСчетов = ОткрытьФормуМодально("ВнешняяОбработка.ОбработкаДляАХ.Форма.ФормаВыбораСчета", ПараметрыФормы);
	
	ОбновитьТаблицуСчетов(ТаблицаСчетов);
			
	ОбновитьПолеСчетов();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьПолеСчетов()
	Счета = "";
	
	Для Каждого Строка из Объект.ТаблицаСчетов Цикл
		Счета =  Счета + Строка(Строка.Код) + ?(Строка.Дт,"Дт","Кт")+ "; ";
	КонецЦикла;	
КонецПроцедуры

&НаСервере
Процедура ОбновитьТаблицуСчетов(ТаблицаСчетов)
	Если ТаблицаСчетов = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Объект.ТаблицаСчетов.Загрузить(ТаблицаСчетов.Выгрузить());	
КонецПроцедуры

&НаКлиенте
Процедура АдресСохраненияНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ВыборФайла(Элемент,Истина);
КонецПроцедуры

&НаКлиенте
Процедура ВыборФайла(Элемент, ПроверятьСуществование=Ложь)
	Режим = РежимДиалогаВыбораФайла.ВыборКаталога; 
	ДиалогОткрытия = Новый ДиалогВыбораФайла(Режим); 
	ДиалогОткрытия.Каталог = ""; 
	ДиалогОткрытия.МножественныйВыбор = Ложь; 
	ДиалогОткрытия.Заголовок = "Выберите каталог"; 
	
	Если ДиалогОткрытия.Выбрать() Тогда 
		АдресСохранения = ДиалогОткрытия.Каталог; 
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура КнопкаВыполнитьНажатие(Команда)
	Если ДатаНач='00010101' или ДатаКон='00010101' Тогда
		Сообщить("Укажиет период выборки!");
		Возврат;
	КонецЕсли;
	
	Если Объект.ТаблицаСчетов.Количество()=0 Тогда
		Сообщить("Выберете счета!");
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Организация) Тогда
		Сообщить("Выберете организацию!");
		Возврат;
	КонецеСли;
	
	Если УровеньСущественности=0 ИЛИ ПроцентОшибки=0 ИЛИ МаксЭлементВыборки=0 Тогда
		Сообщить("'Уровень существенности', 'Процент размера допустимой ошибки', 'Максимальное количество элементов' должны быть больше 0!");
		Возврат;
	КонецЕсли;
	
	СформироватьДокументыЭксель();
КонецПроцедуры

Функция ПолучитьСчетаДляФильтра(ВыбСчет)

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Хозрасчетный.Ссылка
		|ИЗ
		|	ПланСчетов.Хозрасчетный КАК Хозрасчетный
		|ГДЕ
		|	Хозрасчетный.Ссылка В ИЕРАРХИИ(&ВыбСчет)";

	Запрос.УстановитьПараметр("ВыбСчет", ВыбСчет);

	ТЗ = Запрос.Выполнить().Выгрузить();
    Возврат ТЗ.ВыгрузитьКолонку("Ссылка");
	
КонецФункции

Процедура СформироватьДокументыЭксель()	
	ТаблицаСчетов = Объект.ТаблицаСчетов;
	
   // Преобразует реквизит Объект в прикладной объект.
   Обработка = РеквизитФормыВЗначение("Объект");
   // Выполняет пересчет методом, определенным в модуле документа.
   ТабФормат = Обработка.ПодготовитьТабФормат();
   // Преобразует прикладной объект обратно в реквизит.
   ЗначениеВРеквизитФормы(Обработка, "Объект");


	Для Каждого НомерСчета Из ТаблицаСчетов Цикл
		
		Если НомерСчета.Дт и НомерСчета.Кт Тогда
			Продолжить;	
		КонецЕсли;
		
		Запрос = Новый Запрос();
		
		Запрос.УстановитьПараметр("ДатаНач",НачалоДня(ДатаНач));
		Запрос.УстановитьПараметр("ДатаКон",КонецДня(ДатаКон));
		
		ВыбСчет = ПланыСчетов.Хозрасчетный.НайтиПоКоду(НомерСчета.Код);
		
		Если НомерСчета.Дт Тогда
			//СпСчетовДт.Добавить(ВыбСчет);
			Запрос.Параметры.Вставить("СпСчетовДт",ПолучитьСчетаДляФильтра(ВыбСчет));
		КонецЕсли;
		Если НомерСчета.Кт Тогда
			//СпСчетовКт.Добавить(ВыбСчет);
			Запрос.Параметры.Вставить("СпСчетовКт",ПолучитьСчетаДляФильтра(ВыбСчет));
		КонецЕсли;
		
		Запрос.УстановитьПараметр("УровеньСущественности",УровеньСущественности*ПроцентОшибки*0.01);
		Запрос.УстановитьПараметр("Организация",организация);
		
		ТекстЗапроса="ВЫБРАТЬ
		|	ХозрасчетныйОборотыДтКт.Период КАК Период,
		|	ХозрасчетныйОборотыДтКт.Регистратор,
		|	ХозрасчетныйОборотыДтКт.Регистратор.Номер КАК НомерРегистратора,
		|	ХозрасчетныйОборотыДтКт.СчетДт,
		|	ХозрасчетныйОборотыДтКт.СчетКт,
		|	ВЫБОР
		|		КОГДА ХозрасчетныйОборотыДтКт.СуммаОборот > &УровеньСущественности
		|		ТОГДА ЕСТЬNULL(ХозрасчетныйОборотыДтКт.СуммаОборот,0)
		|	КОНЕЦ КАК НаибольшаяСумма,
		|	ВЫБОР
		|		КОГДА ХозрасчетныйОборотыДтКт.СуммаОборот < 0
		|		ТОГДА ХозрасчетныйОборотыДтКт.СуммаОборот
		|	КОНЕЦ КАК ОтрицательнаяСумма,
		|	ВЫБОР
		|		КОГДА ХозрасчетныйОборотыДтКт.СуммаОборот < 0
		|		ТОГДА 1
		|	КОНЕЦ КАК ЭтоОтрицательнаяСумма,
		|	ХозрасчетныйОборотыДтКт.СуммаОборот,";
		
		Если НомерСчета.Дт=Истина Тогда 
			
			ТекстЗапроса = ТекстЗапроса +  "
			
			|	ЕстьNULL(ХозрасчетныйОборотыДтКт.КоличествоОборотДт,0) КАК Количество,
			|	ХозрасчетныйОборотыДтКт.СубконтоДт1 КАК Субконто1,
			|	ХозрасчетныйОборотыДтКт.СубконтоДт2 КАК Субконто2,
			|	ХозрасчетныйОборотыДтКт.СубконтоДт3 КАК Субконто3,
			|	ХозрасчетныйОборотыДтКт.СубконтоКт1 КАК КорСубконто1,
			|	ХозрасчетныйОборотыДтКт.СубконтоКт2 КАК КорСубконто2,
			|	ХозрасчетныйОборотыДтКт.СубконтоКт3 КАК КорСубконто3,
			|	ЕстьNULL(Хозрасчетный.Содержание,"""") КАК СтрСодержание";
			
		Иначе 
			
			ТекстЗапроса=ТекстЗапроса + "
			
			|	ЕстьNULL(ХозрасчетныйОборотыДтКт.КоличествоОборотКт,0) КАК Количество,
			|	ХозрасчетныйОборотыДтКт.СубконтоКт1 КАК Субконто1,
			|	ХозрасчетныйОборотыДтКт.СубконтоКт2 КАК Субконто2,
			|	ХозрасчетныйОборотыДтКт.СубконтоКт3 КАК Субконто3,
			|	ХозрасчетныйОборотыДтКт.СубконтоДт1 КАК КорСубконто1,
			|	ХозрасчетныйОборотыДтКт.СубконтоДт2 КАК КорСубконто2,
			|	ХозрасчетныйОборотыДтКт.СубконтоДт3 КАК КорСубконто3,
			|	ЕстьNULL(Хозрасчетный.Содержание,"""") КАК СтрСодержание";
		КонецЕсли;
		
		ТекстЗапроса = ТекстЗапроса+ "
		
		|ИЗ
		|	РегистрБухгалтерии.Хозрасчетный.ОборотыДтКт(&ДатаНач, &ДатаКон, Запись, "+?(НомерСчета.Дт,"СчетДт В (&СпСчетовДт)","")+", ,"+?(НомерСчета.Кт,"СчетКт В (&СпСчетовКт)","")+", , Организация = &Организация) КАК ХозрасчетныйОборотыДтКт
		|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Хозрасчетный КАК Хозрасчетный
		|	ПО ХозрасчетныйОборотыДтКт.Регистратор = Хозрасчетный.Регистратор
		|		И ХозрасчетныйОборотыДтКт.НомерСтроки = Хозрасчетный.НомерСтроки";
		
		ТекстЗапроса = ТекстЗапроса + "
		
		| УПОРЯДОЧИТЬ ПО
		|			Период";
		
		Запрос.Текст = ТекстЗапроса;
				
		ТаблицаРезультата = Запрос.Выполнить().Выгрузить();
		
		ГенеральнаяСовокупность = ТаблицаРезультата.Итог("СуммаОборот");
		
		СуммаНаибольшихЭлементов = ТаблицаРезультата.Итог("НаибольшаяСумма");
		
		СуммаОтрицательных = ТаблицаРезультата.Итог("ОтрицательнаяСумма");
		КоличествоОтрицательных = ТаблицаРезультата.Итог("ЭтоОтрицательнаяСумма");
		
		КоличествоЭлементовДляПроверки = Окр((ГенеральнаяСовокупность-СуммаНаибольшихЭлементов)*КоэффициентПроверки/(УровеньСущественности*ПроцентОшибки*0.01));
		
		ГенеральнаяСовокупностьВывод = Формат(ГенеральнаяСовокупность,"ЧДЦ=2; ЧРГ=' '");
		СуммаНаибольшихЭлементовВывод=Формат(СуммаНаибольшихЭлементов,"ЧДЦ=2; ЧРГ=' '");
		
		OpenOffice = Новый ComОбъект("com.sun.star.ServiceManager");
		scr = Новый ComОбъект("MSScriptControl.ScriptControl");    
		scr.language = "javascript";
		scr.eval("MassivParametrov = new Array()");
		MassivParametrov = scr.eval("MassivParametrov");
		scr.AddObject("OpenOffice", OpenOffice);
		scr.eval("MassivParametrov[0]=OpenOffice.Bridge_GetStruct('com.sun.star.beans.PropertyValue')");
		scr.eval("MassivParametrov[0].Name='Hidden'");
		scr.eval("MassivParametrov[0].Value=true");
		
		Desktop = OpenOffice.CreateInstance("com.sun.star.frame.Desktop");	
		//URL = ConvertToURL(ПолноеИмяФайла);
		URL = "private:factory/scalc";
		Doc = Desktop.LoadComponentFromURL(URL, "_blank", 0, MassivParametrov);
		
		Doc.lockControllers();
		Doc.addActionLock();
		
		Sheets = Doc.GetSheets();
		Sheet0 = Sheets.GetByIndex(0);
		Sheet0.SetName("ГС"); 
		Sheets.InsertNewByName("Н", 1); 
		Sheet1 = Sheets.GetByIndex(1); 
		Sheets.InsertNewByName("В", 2); 
		Sheet2 = Sheets.GetByIndex(2);
		Sheets.InsertNewByName("РВ", 3);
		Sheet3 = Sheets.GetByIndex(3);
		
		Formats = Doc.getNumberFormats();
		Locale = scr.eval("OpenOffice.Bridge_GetStruct('com.sun.star.lang.Locale')");
		NumberFormat = Formats.getFormatForLocale( 4, Locale );
		
		BorderStyle = ПолучитьСтильГраницы();

		
		Для Индекс = 0 По 3 Цикл
			Sheets.GetByIndex(Индекс).CharFontName = "Calibri";	
			Sheets.GetByIndex(Индекс).CharHeight = 11;	
		КонецЦикла;
		
		
				//!!!Шапка листа 4   "Размер допустимой ошибки (75% Уровня существенности)"
		
		Formats = Doc.getNumberFormats();
		Locale = scr.eval("OpenOffice.Bridge_GetStruct('com.sun.star.lang.Locale')");
		NumberFormat = Formats.getFormatForLocale( 4, Locale );
		
		//!!! задаем формат числа с 2мя знаками
		Sheet3.getCellByPosition(3, 4).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 5).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 6).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 7).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 8).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 9).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 10).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 11).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 12).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 13).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 14).numberFormat = NumberFormat;
		Sheet3.getCellByPosition(3, 15).numberFormat = NumberFormat;
		
		
		
		Sheet3.getCellByPosition(0, 1).setFormula("Организация:");
		Sheet3.getCellByPosition(0, 2).setFormula("Проверяемый период:");
		
		Sheet3.getCellByPosition(2, 0).setFormula("Расчет параметров статистической выборки");
		
		Sheet3.getCellRangeByPosition(2, 0, 2, 0).CharWeight=150;
		Sheet3.getCellRangeByPosition(2, 0, 2, 0).CharHeight=12;
		
		Sheet3.getCellByPosition(2, 1).setFormula(ОРганизация.НаименованиеПолное);
		Sheet3.getCellRangeByPosition(2, 1, 2, 1).CharWeight=150;
		Sheet3.getCellRangeByPosition(2, 1, 2, 1).CharHeight=12;
		
		Sheet3.getCellByPosition(2, 2).setFormula(Формат(ДатаНач,"ДЛФ=Д")+"-"+Формат(ДатаКон,"ДЛФ=Д"));
		Sheet3.getCellRangeByPosition(2, 2, 2, 2).CharWeight=150;
		Sheet3.getCellRangeByPosition(2, 2, 2, 2).CharHeight=12;
		
		
		Sheet3.getCellByPosition(2, 4).setFormula("Уровень существенности");
		Sheet3.getCellByPosition(3, 4).setValue(УровеньСущественности);
		Sheet3.getCellByPosition(4, 4).setFormula("рублей");
		
		
		
		Sheet3.getCellByPosition(2, 5).setFormula("Размер допустимой ошибки( "+Процентошибки+"% от Уровня существенности)");
		Sheet3.getCellByPosition(3, 5).setValue(УровеньСущественности*ПроцентОшибки*0.01);
		Sheet3.getCellByPosition(4, 5).setFormula("рублей");
		
		
		Sheet3.getCellByPosition(2, 6).setFormula("Сумма совокупности данных, подвергаемых выборке");
		Sheet3.getCellByPosition(3, 6).setValue(ГенеральнаяСовокупность);
		Sheet3.getCellByPosition(4, 6).setFormula("рублей");
		
		Sheet3.getCellByPosition(2, 7).setFormula("Количество элементов генеральной совокупности");
		Sheet3.getCellByPosition(3, 7).setValue(Таблицарезультата.Количество());
		Sheet3.getCellByPosition(4, 7).setFormula("элементов");
		
		
		Sheet3.getCellByPosition(2, 8).setFormula("Сумма элементов наибольшей стоимости");
		Sheet3.getCellByPosition(3, 8).setValue(СуммаНаибольшихЭлементов);
		Sheet3.getCellByPosition(4, 8).setFormula("рублей");
		
		Sheet3.getCellByPosition(2, 9).setFormula("Сумма ключевых элементов");
		Sheet3.getCellByPosition(3, 9).setValue(0);
		Sheet3.getCellByPosition(4, 9).setFormula("рублей");
		
		Sheet3.getCellByPosition(2, 10).setFormula("Сумма отрицательных элементов");
		Sheet3.getCellByPosition(3, 10).setValue(СуммаОтрицательных);
		Sheet3.getCellByPosition(4, 10).setFormula("рублей");
		
		Sheet3.getCellByPosition(2, 11).setFormula("Количество отрицательных элементов");
		Sheet3.getCellByPosition(3, 11).setValue(КоличествоОтрицательных);
		Sheet3.getCellByPosition(4, 11).setFormula("элементов");
		
		Sheet3.getCellByPosition(2, 12).setFormula("Определение количества элементов, отбираемых для проверки");
		Sheet3.getCellByPosition(3, 12).setValue(КоличествоЭлементовДляПроверки);
		Sheet3.getCellByPosition(4, 12).setFormula("элементов");
		
		Sheet3.getCellByPosition(2, 13).setFormula("Минимальное количество элементов статистической выборки");
		Sheet3.getCellByPosition(3, 13).setValue(МинЭлементВыборки);
		Sheet3.getCellByPosition(4, 13).setFormula("элементов");
		
		Sheet3.getCellByPosition(2, 14).setFormula("Максимальное количество элементов статистической выборки ");
		Sheet3.getCellByPosition(3, 14).setValue(МаксЭлементВыборки);
		Sheet3.getCellByPosition(4, 14).setFormula("элементов");
		
		Sheet3.getCellByPosition(2, 15).setFormula("Процент размера допустимой ошибки ");
		Sheet3.getCellByPosition(3, 15).setValue(ПроцентОшибки);
		Sheet3.getCellByPosition(4, 15).setFormula("%");
		
		Sheet3.getCellByPosition(2, 16).setFormula("Коэффициент проверки");
		Sheet3.getCellByPosition(3, 16).setValue(КоэффициентПроверки);
		
		
		Sheet3.Columns.GetByIndex(0).Width = 843 * 2;
		Sheet3.Columns.GetByIndex(1).Width = 1943 * 2;
		Sheet3.Columns.GetByIndex(2).Width = 6614 * 2;
		Sheet3.Columns.GetByIndex(3).Width = 3071 * 2;
		Sheet3.Columns.GetByIndex(4).Width = 1429 * 2;
				
		Sheet2.getCellByPosition(0, 1).setFormula("Организация:");

		Sheet2.getCellByPosition(0, 2).setFormula("Проверяемый период:");
		
		Sheet2.getCellByPosition(2, 0).setFormula("Выборочные по счету " + ?(НомерСчета.Дт,"ДТ","КТ")+ " " + Строка(НомерСчета.Код));
	
		Sheet2.getCellRangeByPosition(2, 0, 2, 0).CharWeight = 150;
		Sheet2.getCellRangeByPosition(2, 0, 2, 0).CharHeight = 12;
		
		Sheet2.getCellByPosition(2, 1).setFormula(ОРганизация.НаименованиеПолное);
		Sheet2.getCellRangeByPosition(2, 1, 2, 1).CharWeight = 150;
		Sheet2.getCellRangeByPosition(2, 1, 2, 1).CharHeight = 12;
		
		Sheet2.getCellByPosition(2, 2).setFormula(Формат(ДатаНач,"ДЛФ=Д")+"-"+Формат(ДатаКон,"ДЛФ=Д"));
		Sheet2.getCellRangeByPosition(2, 2, 2, 2).CharWeight = 150;
		Sheet2.getCellRangeByPosition(2, 2, 2, 2).CharHeight = 12;
		
		Sheet1.getCellByPosition(0, 1).setFormula("Организация:");
		Sheet1.getCellByPosition(0, 2).setFormula("Проверяемый период:");
		
		Sheet1.getCellByPosition(2, 0).setFormula( "Наибольшая стоимость по счету " + ?(НомерСчета.Дт,"ДТ","КТ")+ " " + Строка(НомерСчета.Код));
		Sheet1.getCellRangeByPosition(2, 0, 2, 0).CharWeight=150;
		Sheet1.getCellRangeByPosition(2, 0, 2, 0).CharHeight=12;
		
		Sheet1.getCellByPosition(2, 1).setFormula(ОРганизация.НаименованиеПолное);
		Sheet1.getCellRangeByPosition(2, 1, 2, 1).CharWeight=150;
		Sheet1.getCellRangeByPosition(2, 1, 2, 1).CharHeight=12;
		
		Sheet1.getCellByPosition(2, 2).setFormula(Формат(ДатаНач,"ДЛФ=Д")+"-"+Формат(ДатаКон,"ДЛФ=Д"));
		Sheet1.getCellRangeByPosition(2, 2, 2, 2).CharWeight=150;
		Sheet1.getCellRangeByPosition(2, 2, 2, 2).CharHeight=12;

		
		Sheet0.getCellByPosition(0, 1).setFormula("Организация:");
		Sheet0.getCellByPosition(0, 2).setFormula("Проверяемый период:");
		
		Sheet0.getCellByPosition(2, 0).setFormula("Генеральная совокупность по счету " + ?(НомерСчета.Дт,"ДТ","КТ")+ " " + Строка(НомерСчета.Код));
		Sheet0.getCellRangeByPosition(2, 0, 2, 0).CharWeight=150;
		Sheet0.getCellRangeByPosition(2, 0, 3, 0).CharHeight=12;
		
		Sheet0.getCellByPosition(2, 1).setFormula(ОРганизация.НаименованиеПолное);
		Sheet0.getCellRangeByPosition(2, 1, 2, 1).CharWeight=150;
		Sheet0.getCellRangeByPosition(2, 1, 2, 1).CharHeight=12;
		
		Sheet0.getCellByPosition(2, 2).setFormula(Формат(ДатаНач,"ДЛФ=Д")+"-"+Формат(ДатаКон,"ДЛФ=Д"));
		Sheet0.getCellRangeByPosition(2, 2, 2, 2).CharWeight=150;
		Sheet0.getCellRangeByPosition(2, 2, 2, 2).CharHeight=12;
		
		
		ПерваяСтрокаТаблицы = 8;
		ТабФорматКоличество = ТабФормат.Количество() - 1;
		
		//!!!Таблица листа 1
		Для А=0 По ТабФорматКоличество Цикл
			Sheet0.getCellByPosition(А, ПерваяСтрокаТаблицы).SetFormula(ТабФормат.Получить(А).Имя); 
		КонецЦикла;
		
		Для А=0 По ТабФорматКоличество Цикл
			Sheet0.Columns.GetByIndex(А).Width = ТабФормат.Получить(А).Ширина * 2;
		КонецЦикла;
		
		Для А=0 По ТабФорматКоличество Цикл
			Sheet0.getCellRangeByPosition(А, ПерваяСтрокаТаблицы, А, ПерваяСтрокаТаблицы).TableBorder = BorderStyle; 
			
		КонецЦикла;
		
		Для А=0 По ТабФорматКоличество Цикл
			Sheet1.getCellByPosition(А, ПерваяСтрокаТаблицы).SetFormula(ТабФормат.Получить(А).Имя);
		КонецЦикла;
		
		Для А=0 По ТабФорматКоличество Цикл
			Sheet1.Columns.GetByIndex(А).Width = ТабФормат.Получить(А).Ширина * 2;
		КонецЦикла;
		
		Для А=0 По ТабФорматКоличество Цикл
			Sheet1.getCellRangeByPosition(А, ПерваяСтрокаТаблицы, А, ПерваяСтрокаТаблицы).TableBorder = BorderStyle;
		КонецЦикла;
		
		Для А=0 По ТабФорматКоличество Цикл
			Sheet2.getCellByPosition(А, ПерваяСтрокаТаблицы).SetFormula(ТабФормат.Получить(А).Имя);
		КонецЦикла;
		
		Для А=0 По ТабФорматКоличество Цикл
			Sheet2.Columns.GetByIndex(А).Width = ТабФормат.Получить(А).Ширина * 2;
		КонецЦикла;
		
		Для А=0 По ТабФорматКоличество Цикл
			Sheet2.getCellRangeByPosition(А, ПерваяСтрокаТаблицы, А, ПерваяСтрокаТаблицы).TableBorder = BorderStyle;
		КонецЦикла;
		
		НомерОперации = 0;
		НомерСтрокиН=0;
		
		МассивВыбранныхОпераций = Новый Массив;
		
		ГСЧ = Новый ГенераторСлучайныхЧисел();
		
		КоличествоЭлементов = ТаблицаРезультата.Количество() - 1;
				
		//!!!Заполняем таблицы листов 1 и 2
		Для каждого Результат из ТаблицаРезультата Цикл
			НомерОперации = НомерОперации+1;
			
			Sheet0.getCellByPosition(ИндексКолонки("НомерСтр"), НомерОперации+ПерваяСтрокаТаблицы).setFormula(НомерОперации);
			Sheet0.getCellByPosition(ИндексКолонки("Дата"), НомерОперации+ПерваяСтрокаТаблицы).setFormula(Формат(Результат.Период,"ДЛФ=Д")+Символы.Таб);
			Sheet0.getCellByPosition(ИндексКолонки("Документ"), НомерОперации+ПерваяСтрокаТаблицы).setFormula(Строка(ТипЗнч(Результат.Регистратор)) + " " +Строка(Результат.НомерРегистратора));
			Sheet0.getCellByPosition(ИндексКолонки("АналитикаДт"), НомерОперации+ПерваяСтрокаТаблицы).setFormula(ПолучитьСубконтоСтр(Результат.Субконто1,Результат.Субконто2,Результат.Субконто3,";"));
			Sheet0.getCellByPosition(ИндексКолонки("АналитикаКт"), НомерОперации+ПерваяСтрокаТаблицы).setFormula(ПолучитьСубконтоСтр(Результат.КорСубконто1,Результат.КорСубконто2,Результат.КорСубконто3,";"));
			Sheet0.getCellByPosition(ИндексКолонки("Содержание"), НомерОперации+ПерваяСтрокаТаблицы).setFormula(Результат.СтрСодержание);
			
			///!!!фигачим текстовый формат для ячейки, чтобы выводить точку
			//Sheet2.getCellRangeByPosition(ИндексКолонки("СчетДт"), НомерОперации+ПерваяСтрокаТаблицы).numberFormat = "@";
			//Sheet2.getCellRangeByPosition(ИндексКолонки("СчетКт"), НомерОперации+ПерваяСтрокаТаблицы).numberFormat = "@";
			
			Sheet0.getCellByPosition(ИндексКолонки("СчетДт"), НомерОперации+ПерваяСтрокаТаблицы).setFormula(Строка(Результат.СчетДт));
			Sheet0.getCellByPosition(ИндексКолонки("СчетКт"), НомерОперации+ПерваяСтрокаТаблицы).setFormula(Строка(Результат.СчетКт));
			Sheet0.getCellByPosition(ИндексКолонки("Сумма"), НомерОперации+ПерваяСтрокаТаблицы).setValue(Результат.СуммаОборот);
			Sheet0.getCellByPosition(ИндексКолонки("Сумма"), НомерОперации+ПерваяСтрокаТаблицы).numberFormat = NumberFormat;
			Sheet0.getCellByPosition(ИндексКолонки("Количество"), НомерОперации+ПерваяСтрокаТаблицы).setFormula(Результат.Количество);
		
		Для А=0 По ТабФорматКоличество Цикл
			Sheet0.getCellRangeByPosition(А, НомерОперации+ПерваяСтрокаТаблицы, А, НомерОперации+ПерваяСтрокаТаблицы).TableBorder = BorderStyle;
		КонецЦикла;


		Если Результат.НаибольшаяСумма<>Null и 0 < Результат.НаибольшаяСумма Тогда 
				
				НомерСтрокиН = НомерСтрокиН+1;
				
				Sheet0.getCellByPosition(ИндексКолонки("Признак"), НомерОперации+ПерваяСтрокаТаблицы).setFormula("Н");
				
				Sheet1.getCellByPosition(ИндексКолонки("НомерСтр"), НомерСтрокиН+ПерваяСтрокаТаблицы).setFormula(НомерОперации);
				Sheet1.getCellByPosition(ИндексКолонки("Дата"), НомерСтрокиН+ПерваяСтрокаТаблицы).setFormula(Формат(Результат.Период,"ДЛФ=Д")+Символы.Таб);
				Sheet1.getCellByPosition(ИндексКолонки("Документ"), НомерСтрокиН+ПерваяСтрокаТаблицы).setFormula(Строка(ТипЗнч(Результат.Регистратор)) + " " +Строка(Результат.НомерРегистратора));
				Sheet1.getCellByPosition(ИндексКолонки("АналитикаДт"), НомерСтрокиН+ПерваяСтрокаТаблицы).setFormula(ПолучитьСубконтоСтр(Результат.Субконто1,Результат.Субконто2,Результат.Субконто3,";"));
				Sheet1.getCellByPosition(ИндексКолонки("АналитикаКт"), НомерСтрокиН+ПерваяСтрокаТаблицы).setFormula(ПолучитьСубконтоСтр(Результат.КорСубконто1,Результат.КорСубконто2,Результат.КорСубконто3,";"));
				Sheet1.getCellByPosition(ИндексКолонки("Содержание"), НомерСтрокиН+ПерваяСтрокаТаблицы).setFormula(Результат.СтрСодержание);
				
				///!!!фигачим текстовый формат для ячейки, чтобы выводить точку
				//Sheet0.getCellRangeByPosition(ИндексКолонки("СчетДт"), НомерСтрокиН+ПерваяСтрокаТаблицы).numberFormat = "@";
				//Sheet0.getCellRangeByPosition(ИндексКолонки("СчетКт"), НомерСтрокиН+ПерваяСтрокаТаблицы).numberFormat = "@";
				
				Sheet1.getCellByPosition(ИндексКолонки("СчетДт"), НомерСтрокиН+ПерваяСтрокаТаблицы).setFormula(Строка(Результат.СчетДт));
				Sheet1.getCellByPosition(ИндексКолонки("СчетКт"), НомерСтрокиН+ПерваяСтрокаТаблицы).setFormula(Строка(Результат.СчетКт));
				Sheet1.getCellByPosition(ИндексКолонки("Сумма"), НомерСтрокиН+ПерваяСтрокаТаблицы).setValue(Результат.СуммаОборот);//!!!Формат(Результат.СуммаОборот,"ЧДЦ=2; ЧРГ=' '");
				Sheet1.getCellByPosition(ИндексКолонки("Сумма"), НомерОперации+ПерваяСтрокаТаблицы).numberFormat = NumberFormat;
				Sheet1.getCellByPosition(ИндексКолонки("Количество"), НомерСтрокиН+ПерваяСтрокаТаблицы).setFormula(Результат.Количество);
				Sheet1.getCellByPosition(ИндексКолонки("Признак"), НомерСтрокиН+ПерваяСтрокаТаблицы).setFormula("Н");
				
				
				//!!!границы ячеек
				Для А=0 По ТабФорматКоличество Цикл
					Sheet0.getCellRangeByPosition(А, НомерСтрокиН+ПерваяСтрокаТаблицы, А, НомерСтрокиН+ПерваяСтрокаТаблицы).TableBorder = BorderStyle;
				КонецЦикла;				
				
				
				МассивВыбранныхОпераций.Добавить(ТаблицаРезультата.Индекс(Результат)); 
				
			КонецЕсли;
			
			Сообщить("Запись в генеральную последовательность:" + Строка(ТипЗнч(Результат.Регистратор)) + " " +Строка(Результат.НомерРегистратора));
			
		КонецЦикла;	
		
		//!!! Заполняем таблицу листа 3. Как запихнуть в цикл сверху - я не знаю.
		
		//!!! Сколько элементов осталось для статистической выборки после выбора наибольших 
		КоличествоОставшихся = Таблицарезультата.Количество()-МассивВыбранныхОпераций.Количество();
		
		//!!! Теперь исходя из максимального и минимального количеств элементов выборки, и от количества оставшихся
		//!!! прикинем, сколько элементов(числоШаговВыборки) можно выбрать для статистической выборки
		
		
		Если КоличествоОставшихся<МинЭлементВыборки Тогда 
			
			ЧислоШаговВыборки=КоличествоОставшихся; //!!!
			
		ИначеЕсли КоличествоОставшихся>=МинЭлементВыборки И КоличествоОставшихся<=МаксЭлементВыборки Тогда // Осталось посередине между Мин и Макс
			
			Если КоличествоЭлементовДляПроверки < МинЭлементВыборки Тогда // Расчетных меньше минимального - берем минимальное
				
				ЧислошаговВыборки = МинЭлементВыборки;
				
			ИначеЕсли КоличествоЭлементовДляПроверки > МаксЭлементВыборки Тогда // Расчетных больше максимального - берем то что осталось
				
				ЧислошаговВыборки = КоличествоОставшихся;
				
			Иначе // Если расчетных между Мин и Макс, берем меньшее из Расчетного и Оставшихся
				
				ЧислошаговВыборки = Мин(КоличествоЭлементовДляПроверки,КоличествоОставшихся);
				
			КонецЕсли;	
			
		ИначеЕсли КоличествоОставшихся>МаксЭлементВыборки Тогда // Осталось больше максимального - Хватет на все
			
			Если  КоличествоЭлементовДляПроверки<=МаксЭлементВыборки Тогда // Если Расчетное меньше Максимального, то берем большее из Расчетного и Минимального
				
				ЧислоШаговВыборки=Макс(КоличествоЭлементовДляПроверки,МинЭлементВыборки);
				
			ИначеЕсли КоличествоЭлементовДляПроверки>МаксЭлементВыборки Тогда
				
				ЧислоШаговВыборки = МаксЭлементВыборки;
				
			КонецЕСли;
			
			
		КонецЕсли;
		
		//!!!Цикл заполнения листа 3
		//!!! уух. Макс эл цикла равен числу элементов выборки, в массиве выбранных операций все выбранные операции(наибольшие) и добавляются выбранные по статистике
		//!!! цикл ПОКА - для поиска оставшихся не выбранных и не попавших в массив строк
		
		//!!!  ТаблицаНомеровВыборок - для таблички в последнем листе
		ТаблицаНомеровВыборок = Новый таблицазначений;
		ТаблицаНомеровВыборок.Колонки.Добавить("НомерСтроки");
		ТаблицаНомеровВыборок.Колонки.Добавить("НомерВыборки");
		ПорядковыйНомерВыборки=0;
		
		Попытка
			СлучайноеЧислоВыборки = ГСЧ.СлучайноеЧисло(0,КоличествоЭлементов-1);
			СуммаВыбранныхОпераций = 0;
			Для Шаг = 1 По ЧислоШаговВыборки Цикл
				
				Пока МассивВыбранныхОпераций.Найти(СлучайноеЧислоВыборки)<>Неопределено Цикл
					СлучайноеЧислоВыборки = ГСЧ.СлучайноеЧисло(0,КоличествоЭлементов-1);
					
					Если Таблицарезультата.Количество() = МассивВыбранныхОпераций.Количество() Тогда
						Прервать;
					КОнецЕсли;
					
					Сообщить("Поиск случайных элементов");
					
				КонецЦикла;
				
				МассивВыбранныхОпераций.ДОбавить(СлучайноеЧислоВыборки); 
				
				СтрокаВыборки = ТаблицаРезультата[СлучайноеЧислоВыборки];
				
				
				ПорядковыйНомерВыборки=ПорядковыйНомерВыборки+1;
				СтрочкаВПоследнийЛист = ТаблицаНомеровВыборок.Добавить();
				СтрочкаВПоследнийЛист.НомерСтроки = ПорядковыйНомерВыборки;
				СтрочкаВПоследнийЛист.НомерВыборки = ТаблицаРезультата.Индекс(СтрокаВыборки)+1;
				
				Sheet2.getCellByPosition(ИндексКолонки("НомерСтр"), Шаг+ПерваяСтрокаТаблицы).setFormula(ТаблицаРезультата.Индекс(СтрокаВыборки)+1);
				Sheet2.getCellByPosition(ИндексКолонки("Дата"), Шаг+ПерваяСтрокаТаблицы).setFormula(Формат(СтрокаВыборки.Период,"ДЛФ=Д")+Символы.Таб);
				Sheet2.getCellByPosition(ИндексКолонки("Документ"), Шаг+ПерваяСтрокаТаблицы).setFormula(Строка(ТипЗнч(СтрокаВыборки.Регистратор)) + " " +Строка(СтрокаВыборки.НомерРегистратора));
				Sheet2.getCellByPosition(ИндексКолонки("АналитикаДт"), Шаг+ПерваяСтрокаТаблицы).setFormula(ПолучитьСубконтоСтр(СтрокаВыборки.Субконто1,СтрокаВыборки.Субконто2,СтрокаВыборки.Субконто3,";"));
				Sheet2.getCellByPosition(ИндексКолонки("АналитикаКт"), Шаг+ПерваяСтрокаТаблицы).setFormula(ПолучитьСубконтоСтр(СтрокаВыборки.КорСубконто1,СтрокаВыборки.КорСубконто2,СтрокаВыборки.КорСубконто3,";"));
				Sheet2.getCellByPosition(ИндексКолонки("Содержание"), Шаг+ПерваяСтрокаТаблицы).setFormula(СтрокаВыборки.СтрСодержание);
				
				Sheet2.getCellByPosition(ИндексКолонки("СчетДт"), Шаг+ПерваяСтрокаТаблицы).setFormula(Строка(СтрокаВыборки.СчетДт));
				Sheet2.getCellByPosition(ИндексКолонки("СчетКт"), Шаг+ПерваяСтрокаТаблицы).setFormula(Строка(СтрокаВыборки.СчетКт));
				Sheet2.getCellByPosition(ИндексКолонки("Сумма"), Шаг+ПерваяСтрокаТаблицы).setValue(СтрокаВыборки.СуммаОборот);
				Sheet2.getCellByPosition(ИндексКолонки("Сумма"), Шаг+ПерваяСтрокаТаблицы).numberFormat = NumberFormat;
				Sheet2.getCellByPosition(ИндексКолонки("Количество"), Шаг+ПерваяСтрокаТаблицы).setFormula(СтрокаВыборки.Количество);
				Sheet2.getCellByPosition(ИндексКолонки("Признак"), Шаг+ПерваяСтрокаТаблицы).setFormula("В");
				
				//!!!границы ячеек 
				Для А=0 По ТабФорматКоличество Цикл
					Sheet2.getCellRangeByPosition(А, Шаг+ПерваяСтрокаТаблицы, А, Шаг+ПерваяСтрокаТаблицы).TableBorder = BorderStyle;
				КонецЦикла;				
				
				Sheet0.getCellByPosition(ИндексКолонки("Признак"), (ТаблицаРезультата.Индекс(СтрокаВыборки)+1)+ПерваяСтрокаТаблицы).SetFormula("В");
				
				СуммаВыбранныхОпераций = СуммаВыбранныхОпераций+СтрокаВыборки.СуммаОборот;
				
				Сообщить("Запись выборочных элементов:" + Строка(ТипЗнч(СтрокаВыборки.Регистратор)) + " " +Строка(СтрокаВыборки.НомерРегистратора));
				
			КонецЦикла;
			
		Исключение
			//!!!нет результата запроса	
		КонецПопытки;
		
		//!!!Итого Листа 1
		Sheet0.getCellByPosition(ИндексКолонки("НомерСтр"), НомерОперации+ПерваяСтрокаТаблицы+1).setFormula("Итого");
		Sheet0.getCellRangeByPosition(ИндексКолонки("НомерСтр"), НомерОперации+ПерваяСтрокаТаблицы+1, ИндексКолонки("НомерСтр"), НомерОперации+ПерваяСтрокаТаблицы+1).CharWeight=150;
		
		Sheet0.getCellRangeByPosition(ИндексКолонки("Сумма"), НомерОперации+ПерваяСтрокаТаблицы+1, ИндексКолонки("Сумма"), НомерОперации+ПерваяСтрокаТаблицы+1).CharWeight=150;
		Sheet0.getCellRangeByPosition(ИндексКолонки("Количество"), НомерОперации+ПерваяСтрокаТаблицы+1, ИндексКолонки("Количество"), НомерОперации+ПерваяСтрокаТаблицы+1).CharWeight=150;
		
		
		Sheet0.getCellByPosition(ИндексКолонки("Сумма"), НомерОперации+ПерваяСтрокаТаблицы+1).setFormula(ГенеральнаяСовокупностьВывод);
		Sheet0.getCellByPosition(ИндексКолонки("Количество"), НомерОперации+ПерваяСтрокаТаблицы+1).setFormula(Строка(ТаблицаРезультата.Итог("Количество")));
		
		//!!!Итого Листа 2
		НомерСтрокиННомер=НомерСтрокиН+1;
		Sheet1.getCellByPosition(ИндексКолонки("НомерСтр"), НомерСтрокиННомер+ПерваяСтрокаТаблицы).setFormula("Итого");
		Sheet1.getCellRangeByPosition(ИндексКолонки("НомерСтр"), НомерСтрокиННомер+ПерваяСтрокаТаблицы, ИндексКолонки("НомерСтр"), НомерСтрокиННомер+ПерваяСтрокаТаблицы).CharWeight=150;
		
		Sheet1.getCellRangeByPosition(ИндексКолонки("Сумма"), НомерСтрокиННомер+ПерваяСтрокаТаблицы, ИндексКолонки("Сумма"), НомерСтрокиННомер+ПерваяСтрокаТаблицы).CharWeight=150;
		
		Sheet1.getCellByPosition(ИндексКолонки("Сумма"), НомерСтрокиННомер+ПерваяСтрокаТаблицы).setFormula(Строка(СуммаНаибольшихЭлементовВывод));		
		
		//!!!Итого Листа 3
		ЧислоШаговВыборкиНомер=ЧислоШаговВыборки+1;
		Sheet2.getCellByPosition(ИндексКолонки("НомерСтр"), ЧислоШаговВыборкиНомер+ПерваяСтрокаТаблицы).setFormula("Итого");
		Sheet2.getCellRangeByPosition(ИндексКолонки("НомерСтр"), ЧислоШаговВыборкиНомер+ПерваяСтрокаТаблицы, ИндексКолонки("НомерСтр"), ЧислоШаговВыборкиНомер+ПерваяСтрокаТаблицы).CharWeight=150;
		
		Sheet2.getCellRangeByPosition(ИндексКолонки("Сумма"), ЧислоШаговВыборкиНомер+ПерваяСтрокаТаблицы, ИндексКолонки("Сумма"), ЧислоШаговВыборкиНомер+ПерваяСтрокаТаблицы).CharWeight=150;
		
		Sheet2.getCellByPosition(ИндексКолонки("Сумма"), ЧислоШаговВыборкиНомер+ПерваяСтрокаТаблицы).setFormula(Формат(СуммаВыбранныхОпераций,"ЧДЦ=2; ЧРГ=' '"));
		
		//!!! Итого Листа 4
		
		Sheet3.getCellByPosition(2, 9).setFormula("Количество элементов наибольшей стоимости");
		Sheet3.getCellByPosition(3, 9).setFormula(НомерСтрокиН);
		Sheet3.getCellByPosition(4, 9).setFormula("элементов");
		

		Sheet3.getCellByPosition(3, 12).setFormula(ЧислоШаговВыборки); 
		
		ПоследняяСтрока4гоЛиста = 20;
		
		Sheet3.getCellByPosition(1, ПоследняяСтрока4гоЛиста).setFormula("№ п/п");
		Sheet3.getCellByPosition(2, ПоследняяСтрока4гоЛиста).setFormula("Номер элемента выборки");
		
		Sheet3.getCellRangeByPosition(ПоследняяСтрока4гоЛиста, 2, ПоследняяСтрока4гоЛиста, 2).CharWeight=150;
		Sheet3.getCellRangeByPosition(ПоследняяСтрока4гоЛиста, 3, ПоследняяСтрока4гоЛиста, 3).CharWeight=150;	
		
		
		Для каждого СтрокаВыборки из ТаблицаНомеровВыборок Цикл
			Sheet3.getCellByPosition(1, ПоследняяСтрока4гоЛиста+СтрокаВыборки.НомерСтроки).setFormula(СтрокаВыборки.НомерСтроки);
			Sheet3.getCellByPosition(2, ПоследняяСтрока4гоЛиста+СтрокаВыборки.НомерСтроки).setFormula(СтрокаВыборки.Номервыборки);			
			Sheet3.getCellRangeByPosition(1, ПоследняяСтрока4гоЛиста+СтрокаВыборки.НомерСтроки, 2, ПоследняяСтрока4гоЛиста+СтрокаВыборки.НомерСтроки).TableBorder = BorderStyle;				
		КонецЦикла;
				
		СуммаВыбранныхОпераций=0;
		ГенеральнаяСовокупность=0;
		СуммаНаибольшихЭлементов=0;
		//ОбрабатыватьПрерываниеПользователя();
				
		scr.eval("SaveOptions = new Array()");
		SaveOptions = scr.eval("SaveOptions");
		scr.eval("SaveOptions[0]=OpenOffice.Bridge_GetStruct('com.sun.star.beans.PropertyValue')");
		scr.eval("SaveOptions[0].Name='FilterName'");
		scr.eval("SaveOptions[0].Value='Calc8'");
		
		Попытка
			Doc.storeToURL(ConvertToURL(АдресСохранения+"\"+СокрЛП(ШаблонФайла)+" "+НомерСчета.Код+?(НомерСчета.Дт," Дт"," Кт")+".ods"), SaveOptions);
			Сообщить("Файлы сформированы");
		Исключение
			Сообщить(ОписаниеОшибки()+" Файл не сохранен!"); 
		КонецПопытки;
		
				
		Doc.close(true);
	 	Desktop.terminate();
	
	КонецЦикла;
КонецПроцедуры

Функция ПолучитьСубконтоСтр(ЗначСубконто1,ЗначСубконто2,ЗначСубконто3,Суффикс="") Экспорт 
	СтрВозврат="";
	Если ЗначениеЗаполнено(ЗначСубконто1) Тогда
		СтрВозврат = СтрВозврат+СокрЛП(ЗначСубконто1);   
	КонецЕсли;
	Если ЗначениеЗаполнено(ЗначСубконто2) Тогда
		СтрВозврат = СтрВозврат+Суффикс+Символы.ПС+СокрЛП(ЗначСубконто2);   
	КонецЕсли;
	Если ЗначениеЗаполнено(ЗначСубконто3) Тогда
		СтрВозврат = СтрВозврат+Суффикс+Символы.ПС+СокрЛП(ЗначСубконто3);   
	КонецЕсли;
	Возврат СтрВозврат;	
КонецФункции


Функция ИндексКолонки(ИмяСтр) Экспорт 
	СтрНашли="";
	ЗначВозврат=100;
	СтрТаб = ТабФормат.Найти(ИмяСтр,"ИД");
	Если СтрТаб<>Неопределено Тогда
	    ЗначВозврат=ТабФормат.Индекс(СтрТаб);
	КонецЕсли;
	Возврат ЗначВозврат;
КонецФункции


Функция ПолучитьСтильГраницы()  
	BorderLine = scr.eval("OpenOffice.Bridge_GetStruct('com.sun.star.table.BorderLine')");
	BorderLine.OuterLineWidth = 50;
   	BorderLine.InnerLineWidth =  0;
	BorderLine.Color = 0;
	Border = Sheet0.getCellRangeByPosition(0, 0, 0, 0).TableBorder;
	Border.IsTopLineValid          = 1;
    Border.IsBottomLineValid       = 1;
    Border.IsLeftLineValid       = 1;
    Border.IsRightLineValid       = 1;
    Border.IsHorizontalLineValid    = 1;
    Border.IsVerticalLineValid    = 1;
    Border.TopLine       = BorderLine;
    Border.BottomLine       = BorderLine;
    Border.LeftLine       = BorderLine;
    Border.RightLine       = BorderLine;
    Border.HorizontalLine    = BorderLine;
    Border.VerticalLine    = BorderLine;	             ;
	
	Возврат Border;
КонецФункции


Функция ConvertToURL(FileName)
	ИмяФайла =  СтрЗаменить(FileName," ","%20" );
	ИмяФайла =  СтрЗаменить(FileName,":","|" );
	ИмяФайла =  СтрЗаменить(ИмяФайла,"\","/");
	Возврат "file:///" + ИмяФайла;
КонецФункции

&НаКлиенте
Процедура АдресСохраненияПриИзменении(Элемент)
	ШаблонФайла = "";
	
	Если Элемент <> Неопределено И Найти(Элемент.ВыделенныйТекст,"""")>0 Тогда 
		ШаблонФайла = СтрЗаменить(Элемент.ВыделенныйТекст,"""","") ;
	КонецЕсли;
	
	ШаблонФайла = ШаблонФайла + "Журнал";
КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)	
	ПриОткрытииНаСервере();
	ОбновитьПолеСчетов();
	Элемент = Неопределено;
	АдресСохраненияПриИзменении(Элемент);
КонецПроцедуры

&НаСервере
Процедура ПриОткрытииНаСервере()
	МинЭлементВыборки=5;
	МаксЭлементВыборки=150;
	ПроцентОшибки=75;
	КоэффициентПроверки=1.39;
	Если Не ПустаяСтрока(ТаблицаСчетовХранилище) Тогда
		ТаблицаСчетов = ЗначениеИзСтрокиВнутр(ТаблицаСчетовХранилище);
		Объект.ТаблицаСчетов.Загрузить(ТаблицаСчетов);
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	ПередЗакрытиемНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПередЗакрытиемНаСервере()
	//ЭтотОбъект = РеквизитФормыВЗначение("Объект");
	ТаблицаСчетов = РеквизитФормыВЗначение("Объект.ТаблицаСчетов");
	Если ТаблицаСчетов <> Неопределено Тогда
		ТаблицаСчетовХранилище = ЗначениеВСтрокуВнутр(ТаблицаСчетов.Выгрузить());
	КонецЕсли;
КонецПроцедуры