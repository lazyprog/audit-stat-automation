﻿
#Область Начало

// ** НАЧАЛО ** //

&НаКлиенте
Процедура СформироватьОтчет()
	
	// Проверка заполнения данных на форме
	
	Если ДатаНач='00010101' или ДатаКон='00010101' Тогда
		Сообщить("Укажиет период выборки!");
		Возврат;
	КонецЕсли;
	
	Если Объект.ТаблицаСчетов.Количество()=0 Тогда
		Сообщить("Выберете счета!");
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.Организация) Тогда
		Сообщить("Выберете организацию!");
		Возврат;
	КонецеСли;
	
	Если УровеньСущественности=0 ИЛИ ПроцентОшибки=0 ИЛИ МаксЭлементВыборки=0 Тогда
		Сообщить("'Уровень существенности', 'Процент размера допустимой ошибки', 'Максимальное количество элементов' должны быть больше 0!");
		Возврат;
	КонецЕсли;
	
	// Передача данных для обработки на сервере
	
	НаборПечатныхФорм = Новый Соответствие;
	СформироватьОтчетНаСервере(НаборПечатныхФорм);
	
	 // Показ табличных документы пользователю
	
	ПоказатьОтчетыПользователю(НаборПечатныхФорм);
	
	// Сохраним табличные документы в формате xls
	
	//СохранитьОтчетыВФайл(НаборПечатныхФорм, ТипФайлаТабличногоДокумента.XLSX);
		
КонецПроцедуры

&НаСервере
Процедура СформироватьОтчетНаСервере(НаборПечатныхФорм)
	
	
	ДанныеФормы = Новый Структура;
	ДанныеФормы.Вставить("ДатаНач",ДатаНач);
	ДанныеФормы.Вставить("ДатаКон",ДатаКон);
	ДанныеФормы.Вставить("УровеньСущественности",УровеньСущественности);
	ДанныеФормы.Вставить("ПроцентОшибки",ПроцентОшибки);
	ДанныеФормы.Вставить("МаксЭлементВыборки",МаксЭлементВыборки);
	ДанныеФормы.Вставить("МинЭлементВыборки",МинЭлементВыборки);
	ДанныеФормы.Вставить("КоэффициентПроверки",КоэффициентПроверки);
	
	
	КоллекцияПечатныхФорм = Новый ТаблицаЗначений;
	КоллекцияПечатныхФорм.Колонки.Добавить("ТабличныйДокумент");
	КоллекцияПечатныхФорм.Колонки.Добавить("СтрСчет");
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ОбработкаОбъект.СформироватьДокументыНаСервере(ДанныеФормы, КоллекцияПечатныхФорм);
		
	Для каждого СтрокаКоллекции из КоллекцияПечатныхФорм Цикл
		АдресХранилища = ПоместитьВоВременноеХранилище(СтрокаКоллекции.ТабличныйДокумент);
		НаборПечатныхФорм.Вставить(СтрокаКоллекции.СтрСчет, АдресХранилища)	
	КонецЦикла
		
КонецПроцедуры

#КонецОбласти

	
#Область ПрочиеПроцедуры

// ** Прочие процедуры ** //

&НаКлиенте
Функция СуществуетКаталог(АдресСохранения)
	
    КаталогНаДиске = Новый Файл(АдресСохранения);
    Возврат КаталогНаДиске.Существует()
	
КонецФункции

&НаКлиенте
Процедура ПоказатьОтчетыПользователю(НаборПечатныхФорм)
	
	Для каждого ЭлемСтруктуры из НаборПечатныхФорм Цикл
		ПечФормаСтрСчет = ЭлемСтруктуры.Ключ; 
		ПечФормаНаименование = "Выборка по счету "+ПечФормаСтрСчет;
		ТабличныйДокумент = ПолучитьИзВременногоХранилища(ЭлемСтруктуры.Значение);
		ТабличныйДокумент.Показать("Счет "+ПечФормаСтрСчет, ПечФормаНаименование, Истина);
	КонецЦикла
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьОтчетыВФайл(НаборПечатныхФорм, ТипФайла)
	
	// Сохраняем в каталог Документы
	Если ПустаяСтрока(АдресСохранения) Тогда
		КаталогСохранения = КаталогДокументов();
	ИначеЕсли НЕ СуществуетКаталог(АдресСохранения) Тогда
		КаталогСохранения = КаталогДокументов();
	Иначе
		КаталогСохранения = АдресСохранения+"\";
	КонецЕсли;	
	
	Для каждого ЭлемСтруктуры из НаборПечатныхФорм Цикл
		ПечФормаСтрСчет = ЭлемСтруктуры.Ключ; 
		ПечФормаНаименование = "Выборка по счету "+ПечФормаСтрСчет;
		ТабличныйДокумент = ПолучитьИзВременногоХранилища(ЭлемСтруктуры.Значение);
		ТабличныйДокумент.Записать(КаталогСохранения+ПечФормаНаименование+"."+Строка(ТипФайла), ТипФайла);
	КонецЦикла
	
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

#КонецОбласти


 #Область ДействияНаФорме
 
// ** Действия на форме ** //

&НаКлиенте
Процедура КнопкаСформировать(Команда)
	СформироватьОтчет();
КонецПроцедуры

&НаКлиенте
Процедура КнопкаВыбратьСчета(Команда)
	Счета="";
	
	ПараметрыФормы = Новый Структура("ТаблицаСчетов", Объект.ТаблицаСчетов);
	
	ОткрытьФорму("ВнешняяОбработка.AuditAutomationManaged.Форма.ФормаВыбораСчета", ПараметрыФормы,,,,, Новый ОписаниеОповещения("КнопкаВыбратьСчетаЗавершение", ЭтаФорма), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
	
КонецПроцедуры

&НаКлиенте
Процедура КнопкаВыбратьСчетаЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ТаблицаСчетов = Результат;
	
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

#КонецОбласти
