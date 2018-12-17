///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	ТаблицаФайловНаДиске = Новый ТаблицаЗначений;
	ТаблицаФайловНаДиске.Колонки.Добавить("Имя");
	ТаблицаФайловНаДиске.Колонки.Добавить("Файл");
	ТаблицаФайловНаДиске.Колонки.Добавить("ИмяБезРасширения");
	ТаблицаФайловНаДиске.Колонки.Добавить("ПолноеИмя");
	ТаблицаФайловНаДиске.Колонки.Добавить("Путь");
	ТаблицаФайловНаДиске.Колонки.Добавить("Том");
	ТаблицаФайловНаДиске.Колонки.Добавить("Расширение");
	ТаблицаФайловНаДиске.Колонки.Добавить("СтатусПроверки");
	ТаблицаФайловНаДиске.Колонки.Добавить("Количество");
	ТаблицаФайловНаДиске.Колонки.Добавить("Отредактировал");
	ТаблицаФайловНаДиске.Колонки.Добавить("ДатаРедактирования");
	
	ПараметрТом = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("Том");
	
	Если ПараметрТом <> Неопределено Тогда
		ПутьКТому = РаботаСФайламиСлужебный.ПолныйПутьТома(ПараметрТом.Значение);
	КонецЕсли;
	
	МассивФайлов = НайтиФайлы(ПутьКТому,"*", Истина);
	Для Каждого Файл Из МассивФайлов Цикл
		Если Не Файл.ЭтоФайл() Тогда 
			Продолжить;
		КонецЕсли;
		НоваяСтрока = ТаблицаФайловНаДиске.Добавить();
		НоваяСтрока.Имя = Файл.Имя;
		НоваяСтрока.ИмяБезРасширения = Файл.ИмяБезРасширения;
		НоваяСтрока.ПолноеИмя = Файл.ПолноеИмя;
		НоваяСтрока.Путь = Файл.Путь;
		НоваяСтрока.Расширение = Файл.Расширение;
		НоваяСтрока.СтатусПроверки = НСтр("ru = 'Лишние файлы (есть на диске, но сведения о них отсутствуют)'");
		НоваяСтрока.Количество = 1;
		НоваяСтрока.Том = ПараметрТом.Значение;
	КонецЦикла;
	
	РаботаСФайламиСлужебный.ПроверитьЦелостностьФайлов(ТаблицаФайловНаДиске, ПараметрТом.Значение);
	
	СтандартнаяОбработка = Ложь;
	
	ДокументРезультат.Очистить();
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	
	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("ТаблицаПроверкиТома", ТаблицаФайловНаДиске);
	
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, Настройки, ДанныеРасшифровки);
	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных, ДанныеРасшифровки, Истина);
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	КомпоновщикНастроек.ПользовательскиеНастройки.ДополнительныеСвойства.Вставить("ОтчетПустой", ТаблицаФайловНаДиске.Количество() = 0);
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	НастройкиОтчета = КомпоновщикНастроек.ПолучитьНастройки();
	Том = НастройкиОтчета.ПараметрыДанных.Элементы.Найти("Том").Значение;
	
	Если Не ЗначениеЗаполнено(Том) Тогда
		ОбщегоНазначения.СообщитьПользователю(
			НСтр("ru = 'Не заполнено значение параметра Том'"), , );
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли