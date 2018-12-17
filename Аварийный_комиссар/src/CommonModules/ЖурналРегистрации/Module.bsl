///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Процедура пакетной записи сообщений в журнал регистрации.
// После записи переменная СобытияДляЖурналаРегистрации очищается.
//
// Параметры:
//  СобытияДляЖурналаРегистрации - СписокЗначений - где Значение - структура со свойствами:
//              * ИмяСобытия  - Строка - имя записываемого события.
//              * ПредставлениеУровня  - Строка - представление значений коллекции УровеньЖурналаРегистрации.
//                                       Доступные значения: "Информация", "Ошибка", "Предупреждение", "Примечание".
//              * Комментарий - Строка - комментарий события.
//              * ДатаСобытия - Дата   - дата события, подставляется в комментарий при записи.
//
Процедура ЗаписатьСобытияВЖурналРегистрации(СобытияДляЖурналаРегистрации) Экспорт
	
	Если ТипЗнч(СобытияДляЖурналаРегистрации) <> Тип("СписокЗначений") Тогда
		Возврат;
	КонецЕсли;	
	
	Если СобытияДляЖурналаРегистрации.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СообщениеЖурнала Из СобытияДляЖурналаРегистрации Цикл
		ЗначениеСообщения = СообщениеЖурнала.Значение;
		ИмяСобытия = ЗначениеСообщения.ИмяСобытия;
		УровеньСобытия = УровеньСобытияПоПредставлению(ЗначениеСообщения.ПредставлениеУровня);
		ДатаСобытия = ТекущаяДатаСеанса();
		Если ЗначениеСообщения.Свойство("ДатаСобытия") И ЗначениеЗаполнено(ЗначениеСообщения.ДатаСобытия) Тогда
			ДатаСобытия = ЗначениеСообщения.ДатаСобытия;
		КонецЕсли;
		Комментарий = Строка(ДатаСобытия) + " " + ЗначениеСообщения.Комментарий;
		ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньСобытия,,, Комментарий);
	КонецЦикла;
	СобытияДляЖурналаРегистрации.Очистить();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Записывает сообщение в журнал регистрации.
//
//  Параметры: 
//   ИмяСобытия       - Строка - имя события для журнала регистрации.
//   Уровень          - УровеньЖурналаРегистрации - уровни важности событий журнала регистрации.
//   ОбъектМетаданных - ОбъектМетаданных - объект метаданных, к которому относится событие.
//   Данные           - ЛюбаяСсылка, Число, Строка, Дата, Булево, Неопределено, Тип - Данные, с которыми связано событие.
//                      Рекомендуется указывать ссылки на объекты данных (элементы справочников, документы, к которым относится событие).
//   Комментарий      - Строка - комментарий для события журнала.
//
Процедура ДобавитьСообщениеДляЖурналаРегистрации(Знач ИмяСобытия, Знач Уровень,
		Знач ОбъектМетаданных = Неопределено, Знач Данные = Неопределено, Знач Комментарий = "") Экспорт
		
	Если ПустаяСтрока(ИмяСобытия) Тогда
		ИмяСобытия = "Событие"; // не локализуется, чтобы не допускать остановки запуска в частично переведенной конфигурации
	КонецЕсли;

	ЗаписьЖурналаРегистрации(ИмяСобытия, Уровень, ОбъектМетаданных, Данные, Комментарий, РежимТранзакцииЗаписиЖурналаРегистрации.Независимая);
	
КонецПроцедуры

// Выполняет чтение событий журнала регистрации в соответствии с установленным отбором.
//
// Параметры:
//
//     ПараметрыОтчета - Структура - Содержит параметры для чтения событий журнала регистрации. Содержит поля:
//         Журнал                  - ТаблицаЗначений         - Содержит записи журнала регистрации.
//         ОтборЖурналаНаКлиенте   - Структура               - Настройки отбора для чтения записей журнала регистрации.
//         КоличествоСобытий       - Число                   - Ограничение числа считываемых событий журнала.
//         УникальныйИдентификатор - УникальныйИдентификатор - Уникальный идентификатор формы.
//         МенеджерВладельца       - Произвольный            - Менеджер объекта, в форме которого отображается журнал
//                                                             регистрации, необходим для обратного вызова функций
//                                                             оформления.
//         ДобавлятьДополнительныеКолонки - Булево           - Определяет необходимость обратного вызова для добавления
//                                                             дополнительных колонок.
//     АдресХранилища - Строка, УникальныйИдентификатор - Адрес временного хранилища для результата.
//
// Результат представляет собой структуру с полями:
//     СобытияЖурнала - ТаблицаЗначений - Отобранные события.
//
Процедура ПрочитатьСобытияЖурналаРегистрации(ПараметрыОтчета, АдресХранилища) Экспорт
	
	ОтборЖурналаНаКлиенте          = ПараметрыОтчета.ОтборЖурналаРегистрации;
	КоличествоСобытий              = ПараметрыОтчета.КоличествоПоказываемыхСобытий;
	МенеджерВладельца              = ПараметрыОтчета.МенеджерВладельца;
	ДобавлятьДополнительныеКолонки = ПараметрыОтчета.ДобавлятьДополнительныеКолонки;
	
	// Проверяем параметры на корректность.
	ДатаНачала    = Неопределено;
	ДатаОкончания = Неопределено;
	ДатыОтбораУказаны= ОтборЖурналаНаКлиенте.Свойство("ДатаНачала", ДатаНачала) И ОтборЖурналаНаКлиенте.Свойство("ДатаОкончания", ДатаОкончания)
		И ЗначениеЗаполнено(ДатаНачала) И ЗначениеЗаполнено(ОтборЖурналаНаКлиенте.ДатаОкончания);
		
	Если ДатыОтбораУказаны И ДатаНачала > ДатаОкончания Тогда
		ВызватьИсключение НСтр("ru = 'Некорректно заданы условия отбора журнала регистрации. Дата начала больше даты окончания.'");
	КонецЕсли;
	СмещениеВремениСервера = СмещениеВремениСервера();
	
	// Подготовка отбора
	Отбор = Новый Структура;
	Для Каждого ЭлементОтбора Из ОтборЖурналаНаКлиенте Цикл
		Отбор.Вставить(ЭлементОтбора.Ключ, ЭлементОтбора.Значение);
	КонецЦикла;
	ПреобразованиеОтбора(Отбор, СмещениеВремениСервера);
	
	// Выгрузка отбираемых событий и формирование структуры таблицы.
	СобытияЖурнала = Новый ТаблицаЗначений;
	ВыгрузитьЖурналРегистрации(СобытияЖурнала, Отбор, , , КоличествоСобытий);
	
	СобытияЖурнала.Колонки.Дата.Имя = "ДатаНаСервере";
	СобытияЖурнала.Колонки.Добавить("Дата", Новый ОписаниеТипов("Дата"));
	
	СобытияЖурнала.Колонки.Добавить("НомерРисунка", Новый ОписаниеТипов("Число"));
	СобытияЖурнала.Колонки.Добавить("АдресДанных",  Новый ОписаниеТипов("Строка"));
	
	Если ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		СобытияЖурнала.Колонки.Добавить("РазделениеДанныхСеанса", Новый ОписаниеТипов("Строка"));
		СобытияЖурнала.Колонки.Добавить("ПредставлениеРазделенияДанныхСеанса", Новый ОписаниеТипов("Строка"));
	КонецЕсли;
	
	Если ДобавлятьДополнительныеКолонки Тогда
		МенеджерВладельца.ДобавитьДополнительныеКолонкиСобытия(СобытияЖурнала);
	КонецЕсли;
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных()
	   И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.БазоваяФункциональностьВМоделиСервиса") Тогда
		
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		ПсевдонимыПользователей    = Новый Соответствие();
	Иначе
		МодульРаботаВМоделиСервиса = Неопределено;
		ПсевдонимыПользователей    = Неопределено;
	КонецЕсли;
	
	Для Каждого СобытиеЖурнала Из СобытияЖурнала Цикл
		СобытиеЖурнала.Дата = СобытиеЖурнала.ДатаНаСервере - СмещениеВремениСервера;
		
		// Заполнение номеров картинок строк.
		МенеджерВладельца.УстановитьНомерРисунка(СобытиеЖурнала);
		
		Если ДобавлятьДополнительныеКолонки Тогда
			// Заполнение дополнительных полей, определенных только у владельца.
			МенеджерВладельца.ЗаполнитьДополнительныеКолонкиСобытия(СобытиеЖурнала);
		КонецЕсли;
		
		// Преобразование массива метаданных в список значений.
		СписокПредставленийМетаданных = Новый СписокЗначений;
		Если ТипЗнч(СобытиеЖурнала.ПредставлениеМетаданных) = Тип("Массив") Тогда
			СписокПредставленийМетаданных.ЗагрузитьЗначения(СобытиеЖурнала.ПредставлениеМетаданных);
			СобытиеЖурнала.ПредставлениеМетаданных = СписокПредставленийМетаданных;
		Иначе
			СобытиеЖурнала.ПредставлениеМетаданных = Строка(СобытиеЖурнала.ПредставлениеМетаданных);
		КонецЕсли;
		
		// Преобразование массива "ПредставлениеРазделенияДанныхСеанса" в список значений.
		Если ОбщегоНазначения.РазделениеВключено()
			И Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
			ПолноеПредставлениеРазделенияДанныхСеанса = "";
			
			РазделениеДанныхСеанса = СобытиеЖурнала.РазделениеДанныхСеанса;
			СписокРеквизитовРазделенияДанных = Новый СписокЗначений;
			Для Каждого РазделительСеанса Из РазделениеДанныхСеанса Цикл
				ПредставлениеРазделителя = Метаданные.ОбщиеРеквизиты.Найти(РазделительСеанса.Ключ).Синоним;
				ПредставлениеРазделителя = ПредставлениеРазделителя + " = " + РазделительСеанса.Значение;
				ЗначениеРазделителя = РазделительСеанса.Ключ + "=" + РазделительСеанса.Значение;
				СписокРеквизитовРазделенияДанных.Добавить(ЗначениеРазделителя, ПредставлениеРазделителя);
				ПолноеПредставлениеРазделенияДанныхСеанса = ?(Не ПустаяСтрока(ПолноеПредставлениеРазделенияДанныхСеанса),
				                                            ПолноеПредставлениеРазделенияДанныхСеанса + "; ", "")
				                                            + ПредставлениеРазделителя;
			КонецЦикла;
			СобытиеЖурнала.РазделениеДанныхСеанса = СписокРеквизитовРазделенияДанных;
			СобытиеЖурнала.ПредставлениеРазделенияДанныхСеанса = ПолноеПредставлениеРазделенияДанныхСеанса;
		КонецЕсли;
		
		// Обработка данных специальных событий.
		Если СобытиеЖурнала.Событие = "_$Access$_.Access" Тогда
			УстановитьСтрокуАдресаДанных(СобытиеЖурнала);
			
			Если СобытиеЖурнала.Данные <> Неопределено Тогда
				СобытиеЖурнала.Данные = ?(СобытиеЖурнала.Данные.Данные = Неопределено, "", "...");
			КонецЕсли;
			
		ИначеЕсли СобытиеЖурнала.Событие = "_$Access$_.AccessDenied" Тогда
			УстановитьСтрокуАдресаДанных(СобытиеЖурнала);
			
			Если СобытиеЖурнала.Данные <> Неопределено Тогда
				Если СобытиеЖурнала.Данные.Свойство("Право") Тогда
					СобытиеЖурнала.Данные = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Право: %1'"), 
						СобытиеЖурнала.Данные.Право);
				Иначе
					СобытиеЖурнала.Данные = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Действие: %1%2'"), 
						СобытиеЖурнала.Данные.Действие, ?(СобытиеЖурнала.Данные.Данные = Неопределено, "", ", ...") );
				КонецЕсли;
			КонецЕсли;
			
		ИначеЕсли СобытиеЖурнала.Событие = "_$Session$_.Authentication"
		      Или СобытиеЖурнала.Событие = "_$Session$_.AuthenticationError" Тогда
			
			УстановитьСтрокуАдресаДанных(СобытиеЖурнала);
			
			СобытиеЖурналаДанные = "";
			Если СобытиеЖурнала.Данные <> Неопределено Тогда
				Для Каждого КлючИЗначение Из СобытиеЖурнала.Данные Цикл
					Если ЗначениеЗаполнено(СобытиеЖурналаДанные) Тогда
						СобытиеЖурналаДанные = СобытиеЖурналаДанные + ", ...";
						Прервать;
					КонецЕсли;
					СобытиеЖурналаДанные = КлючИЗначение.Ключ + ": " + КлючИЗначение.Значение;
				КонецЦикла;
			КонецЕсли;
			СобытиеЖурнала.Данные = СобытиеЖурналаДанные;
			
		ИначеЕсли СобытиеЖурнала.Событие = "_$User$_.Delete" Тогда
			УстановитьСтрокуАдресаДанных(СобытиеЖурнала);
			
			СобытиеЖурналаДанные = "";
			Если СобытиеЖурнала.Данные <> Неопределено Тогда
				Для каждого КлючИЗначение Из СобытиеЖурнала.Данные Цикл
					СобытиеЖурналаДанные = КлючИЗначение.Ключ + ": " + КлючИЗначение.Значение;
					Прервать;
				КонецЦикла;
			КонецЕсли;
			СобытиеЖурнала.Данные = СобытиеЖурналаДанные;
			
		ИначеЕсли СобытиеЖурнала.Событие = "_$User$_.New"
		      ИЛИ СобытиеЖурнала.Событие = "_$User$_.Update" Тогда
			УстановитьСтрокуАдресаДанных(СобытиеЖурнала);
			
			ИмяПользователяИБ = "";
			Если СобытиеЖурнала.Данные <> Неопределено Тогда
				СобытиеЖурнала.Данные.Свойство("Имя", ИмяПользователяИБ);
			КонецЕсли;
			СобытиеЖурнала.Данные = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Имя: %1, ...'"), ИмяПользователяИБ);
			
		КонецЕсли;
		
		УстановитьПривилегированныйРежим(Истина);
		// Уточнение имени пользователя.
		Если СобытиеЖурнала.Пользователь = Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000") Тогда
			СобытиеЖурнала.ИмяПользователя = НСтр("ru = '<Неопределен>'");
			
		ИначеЕсли СобытиеЖурнала.ИмяПользователя = "" Тогда
			СобытиеЖурнала.ИмяПользователя = Пользователи.ПолноеИмяНеУказанногоПользователя();
			
		ИначеЕсли ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(СобытиеЖурнала.Пользователь) = Неопределено Тогда
			СобытиеЖурнала.ИмяПользователя = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1 <Удален>'"), СобытиеЖурнала.ИмяПользователя);
		КонецЕсли;
		
		Если МодульРаботаВМоделиСервиса <> Неопределено Тогда
			Если ПсевдонимыПользователей.Получить(СобытиеЖурнала.Пользователь) = Неопределено Тогда
				ПсевдонимПользователя = МодульРаботаВМоделиСервиса.ПсевдонимПользователяИнформационнойБазы(СобытиеЖурнала.Пользователь);
				ПсевдонимыПользователей.Вставить(СобытиеЖурнала.Пользователь, ПсевдонимПользователя);
			Иначе
				ПсевдонимПользователя = ПсевдонимыПользователей.Получить(СобытиеЖурнала.Пользователь);
			КонецЕсли;
			
			Если ЗначениеЗаполнено(ПсевдонимПользователя) Тогда
				СобытиеЖурнала.ИмяПользователя = ПсевдонимПользователя;
			КонецЕсли;
		КонецЕсли;
		
		// Преобразование идентификатора в имя для использования в дальнейшем при установке отборе.
		СобытиеЖурнала.Пользователь = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(СобытиеЖурнала.Пользователь);
		УстановитьПривилегированныйРежим(Ложь);
	КонецЦикла;
	
	// Успешное завершение
	Результат = Новый Структура;
	Результат.Вставить("СобытияЖурнала", СобытияЖурнала);
	
	ПоместитьВоВременноеХранилище(Результат, АдресХранилища);
КонецПроцедуры

// Создает пользовательское представление отбора журнала регистрации.
//
// Параметры:
//  ПредставлениеОтбора - Строка - строка, содержащая пользовательское представление отбора.
//  ОтборЖурналаРегистрации - Структура - значения отбора журнала регистрации.
//  ОтборЖурналаРегистрацииПоУмолчанию - Структура - значения отбора журнала регистрации по умолчанию 
//     (не включаются в пользовательское представления).
//
Процедура СформироватьПредставлениеОтбора(ПредставлениеОтбора, ОтборЖурналаРегистрации, 
		ОтборЖурналаРегистрацииПоУмолчанию = Неопределено) Экспорт
	
	ПредставлениеОтбора = "";
	// Интервал
	ДатаНачалаИнтервала    = Неопределено;
	ДатаОкончанияИнтервала = Неопределено;
	Если Не ОтборЖурналаРегистрации.Свойство("ДатаНачала", ДатаНачалаИнтервала)
		Или ДатаНачалаИнтервала = Неопределено Тогда
		ДатаНачалаИнтервала    = '00010101000000';
	КонецЕсли;
	
	Если Не ОтборЖурналаРегистрации.Свойство("ДатаОкончания", ДатаОкончанияИнтервала)
		Или ДатаОкончанияИнтервала = Неопределено Тогда
		ДатаОкончанияИнтервала = '00010101000000';
	КонецЕсли;
	
	Если Не (ДатаНачалаИнтервала = '00010101000000' И ДатаОкончанияИнтервала = '00010101000000') Тогда
		ПредставлениеОтбора = ПредставлениеПериода(ДатаНачалаИнтервала, ДатаОкончанияИнтервала);
	КонецЕсли;
	
	ДобавитьОграничениеВПредставлениеОтбора(ОтборЖурналаРегистрации, ПредставлениеОтбора, "Пользователь");
	ДобавитьОграничениеВПредставлениеОтбора(ОтборЖурналаРегистрации, ПредставлениеОтбора,
		"Событие", ОтборЖурналаРегистрацииПоУмолчанию);
	ДобавитьОграничениеВПредставлениеОтбора(ОтборЖурналаРегистрации, ПредставлениеОтбора,
		"ИмяПриложения", ОтборЖурналаРегистрацииПоУмолчанию);
	ДобавитьОграничениеВПредставлениеОтбора(ОтборЖурналаРегистрации, ПредставлениеОтбора, "Сеанс");
	ДобавитьОграничениеВПредставлениеОтбора(ОтборЖурналаРегистрации, ПредставлениеОтбора, "Уровень");
	
	// Остальные ограничения указываем просто по представлением, без указания значений ограничения.
	Для Каждого ЭлементОтбора Из ОтборЖурналаРегистрации Цикл
		ИмяОграничения = ЭлементОтбора.Ключ;
		Если ВРег(ИмяОграничения) = ВРег("ДатаНачала")
			Или ВРег(ИмяОграничения) = ВРег("ДатаОкончания")
			Или ВРег(ИмяОграничения) = ВРег("Событие")
			Или ВРег(ИмяОграничения) = ВРег("ИмяПриложения")
			Или ВРег(ИмяОграничения) = ВРег("Пользователь")
			Или ВРег(ИмяОграничения) = ВРег("Сеанс")
			Или ВРег(ИмяОграничения) = ВРег("Уровень") Тогда
			Продолжить; // Интервал и особые ограничения уже выводили.
		КонецЕсли;
		
		// Для некоторых ограничений меняем представление.
		Если ВРег(ИмяОграничения) = ВРег("ИмяПриложения") Тогда
			ИмяОграничения = НСтр("ru = 'Приложение'");
		ИначеЕсли ВРег(ИмяОграничения) = ВРег("СтатусТранзакции") Тогда
			ИмяОграничения = НСтр("ru = 'Статус транзакции'");
		ИначеЕсли ВРег(ИмяОграничения) = ВРег("ПредставлениеДанных") Тогда
			ИмяОграничения = НСтр("ru = 'Представление данных'");
		ИначеЕсли ВРег(ИмяОграничения) = ВРег("РабочийСервер") Тогда
			ИмяОграничения = НСтр("ru = 'Рабочий сервер'");
		ИначеЕсли ВРег(ИмяОграничения) = ВРег("ОсновнойIPПорт") Тогда
			ИмяОграничения = НСтр("ru = 'Основной IP порт'");
		ИначеЕсли ВРег(ИмяОграничения) = ВРег("ВспомогательныйIPПорт") Тогда
			ИмяОграничения = НСтр("ru = 'Вспомогательный IP порт'");
		ИначеЕсли ВРег(ИмяОграничения) = ВРег("РазделениеДанныхСеанса") Тогда
			ИмяОграничения = НСтр("ru = 'Разделение данных сеанса'");
		КонецЕсли;
		
		Если Не ПустаяСтрока(ПредставлениеОтбора) Тогда 
			ПредставлениеОтбора = ПредставлениеОтбора + "; ";
		КонецЕсли;
		ПредставлениеОтбора = ПредставлениеОтбора + ИмяОграничения;
		
	КонецЦикла;
	
	Если ПустаяСтрока(ПредставлениеОтбора) Тогда
		ПредставлениеОтбора = НСтр("ru = 'Не установлен'");
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
//
Процедура ПоместитьДанныеВоВременноеХранилище(СобытияЖурнала, УникальныйИдентификатор) Экспорт
	
	Для Каждого СтрокаСобытие Из СобытияЖурнала Цикл
		Если ПустаяСтрока(СтрокаСобытие.АдресДанных) Тогда
			АдресДанных = "";
		Иначе
			ЧтениеXML = Новый ЧтениеXML();
			ЧтениеXML.УстановитьСтроку(СтрокаСобытие.АдресДанных);
			АдресДанных = СериализаторXDTO.ПрочитатьXML(ЧтениеXML);
		КонецЕсли;
		СтрокаСобытие.АдресДанных = ПоместитьВоВременноеХранилище(АдресДанных, УникальныйИдентификатор);
	КонецЦикла;
	
КонецПроцедуры

// Определяет смещение времени сервера относительно времени программы.
//
// Возвращаемое значение:
//   Число - Смещение времени в секундах.
//       Может использоваться для приведения фильтров, применяемых к журналу, к дате сервера,
//       а также для приведения дат, полученных из журнала, к датам программы.
//
Функция СмещениеВремениСервера() Экспорт
	
	СмещениеВремениСервера = ТекущаяДата() - ТекущаяДатаСеанса();
	Если СмещениеВремениСервера >= -1 И СмещениеВремениСервера <= 1 Тогда
		СмещениеВремениСервера = 0;
	КонецЕсли;
	Возврат СмещениеВремениСервера;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Преобразование отбора.
//
// Параметры:
//  Отбор - отбор - передаваемый отбор.
//
Процедура ПреобразованиеОтбора(Отбор, СмещениеВремениСервера)
	
	Для Каждого ЭлементОтбора Из Отбор Цикл
		Если ТипЗнч(ЭлементОтбора.Значение) = Тип("СписокЗначений") Тогда
			ПреобразованиеЭлементаОтбора(Отбор, ЭлементОтбора);
		ИначеЕсли ВРег(ЭлементОтбора.Ключ) = ВРег("Транзакция") Тогда
			Если СтрНайти(ЭлементОтбора.Значение, "(") = 0 Тогда
				Отбор.Вставить(ЭлементОтбора.Ключ, "(" + ЭлементОтбора.Значение);
			КонецЕсли;
		ИначеЕсли СмещениеВремениСервера <> 0
			И (ВРег(ЭлементОтбора.Ключ) = ВРег("ДатаНачала") Или ВРег(ЭлементОтбора.Ключ) = ВРег("ДатаОкончания")) Тогда
			Отбор.Вставить(ЭлементОтбора.Ключ, ЭлементОтбора.Значение + СмещениеВремениСервера);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Преобразование элемента отбора.
//
// Параметры:
//  Отбор - отбор - передаваемый отбор.
//  Отбор - Элемент отбора - элемент передаваемого отбора.
//
Процедура ПреобразованиеЭлементаОтбора(Отбор, ЭлементОтбора)
	
	КлючСтруктурыОтбора = ЭлементОтбора.Ключ;
	// Эта процедура вызывается, если элемент отбора является списком значений,
	// в отборе же должен быть массив значений. Преобразуем список в массив.
	Если ВРег(КлючСтруктурыОтбора) = ВРег("РазделениеДанныхСеанса") Тогда
		НовоеЗначение = Новый Структура;
	Иначе
		НовоеЗначение = Новый Массив;
	КонецЕсли;
	
	КлючСтруктурыОтбора = ЭлементОтбора.Ключ;
	
	Для Каждого ЗначениеИзСписка Из ЭлементОтбора.Значение Цикл
		Если ВРег(КлючСтруктурыОтбора) = ВРег("Уровень") Тогда
			// Уровни сообщений представлены строкой, требуется преобразование в значение перечисления.
			НовоеЗначение.Добавить(Обработки.ЖурналРегистрации.УровеньЖурналаРегистрацииЗначениеПоИмени(ЗначениеИзСписка.Значение));
		ИначеЕсли ВРег(КлючСтруктурыОтбора) = ВРег("СтатусТранзакции") Тогда
			// Статусы транзакций представлены строкой, требуется преобразование в значение перечисления.
			НовоеЗначение.Добавить(Обработки.ЖурналРегистрации.СтатусТранзакцииЗаписиЖурналаРегистрацииЗначениеПоИмени(ЗначениеИзСписка.Значение));
		ИначеЕсли ВРег(КлючСтруктурыОтбора) = ВРег("РазделениеДанныхСеанса") Тогда
			МассивЗначенийРазделителей = Новый Массив;
			КлючСтруктурыОтбора = "РазделениеДанныхСеанса";
			РазделениеДанныхМассив = СтрРазделить(ЗначениеИзСписка.Значение, "=", Истина);
			
			ЗначенияРазделителя = СтрРазделить(РазделениеДанныхМассив[1], ",", Истина);
			Для Каждого ЗначениеРазделителя Из ЗначенияРазделителя Цикл
				ЭлементОтбораПоРазделителю = Новый Структура("Значение, Использование", Число(ЗначениеРазделителя), Истина);
				МассивЗначенийРазделителей.Добавить(ЭлементОтбораПоРазделителю);
			КонецЦикла;
			
			НовоеЗначение.Вставить(РазделениеДанныхМассив[0], МассивЗначенийРазделителей);
			
		Иначе
			ЗначенияОтбора = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(ЗначениеИзСписка.Значение, Символы.ПС);
			Для Каждого ЗначениеОтбора Из ЗначенияОтбора Цикл
				НовоеЗначение.Добавить(ЗначениеОтбора);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
	Отбор.Вставить(ЭлементОтбора.Ключ, НовоеЗначение);
	
КонецПроцедуры

// Добавить ограничение в представление отбора.
//
// Параметры:
//  ОтборЖурналаРегистрации - Отбор - отбор журнала регистрации.
//  ПредставлениеОтбора - Строка - представление отбора.
//  ИмяОграничения - Строка - имя ограничения.
//  ОтборЖурналаРегистрацииПоУмолчанию - Отбор - отбор журнала регистрации по умолчанию.
//
Процедура ДобавитьОграничениеВПредставлениеОтбора(ОтборЖурналаРегистрации, ПредставлениеОтбора, ИмяОграничения,
	ОтборЖурналаРегистрацииПоУмолчанию = Неопределено)
	
	Если Не ОтборЖурналаРегистрации.Свойство(ИмяОграничения) Тогда
		Возврат;
	КонецЕсли;
	
	СписокОграничений = ОтборЖурналаРегистрации[ИмяОграничения];
	Ограничение       = "";
	
	// Не формируем представление отбора, если его значение соответствует значению отбора по умолчанию.
	Если ОтборЖурналаРегистрацииПоУмолчанию <> Неопределено Тогда
		СписокОграниченийПоУмолчанию = "";
		Если ОтборЖурналаРегистрацииПоУмолчанию.Свойство(ИмяОграничения, СписокОграниченийПоУмолчанию) 
			И ОбщегоНазначенияКлиентСервер.СпискиЗначенийИдентичны(СписокОграниченийПоУмолчанию, СписокОграничений) Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	Если ИмяОграничения = "Событие" И СписокОграничений.Количество() > 5 Тогда
		
		Ограничение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'События (%1)'"), СписокОграничений.Количество());
		
	ИначеЕсли ИмяОграничения = "Сеанс" И СписокОграничений.Количество() > 3 Тогда
		
		Ограничение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Сеансы (%1)'"), СписокОграничений.Количество());
		
	Иначе
		
		Для Каждого ЭлементСписка Из СписокОграничений Цикл
			
			Если Не ПустаяСтрока(Ограничение) Тогда
				Ограничение = Ограничение + ", ";
			КонецЕсли;
			
			Если (ВРег(ИмяОграничения) = ВРег("Сеанс")
			ИЛИ ВРег(ИмяОграничения) = ВРег("Уровень"))
			И ПустаяСтрока(Ограничение) Тогда
			
				Ограничение = НСтр("ru = '[ИмяОграничения]: [Значение]'");
				Ограничение = СтрЗаменить(Ограничение, "[Значение]", ЭлементСписка.Значение);
				Ограничение = СтрЗаменить(Ограничение, "[ИмяОграничения]", ИмяОграничения);
				
			ИначеЕсли ВРег(ИмяОграничения) = ВРег("Сеанс")
			ИЛИ ВРег(ИмяОграничения) = ВРег("Уровень")Тогда
				Ограничение = Ограничение + ЭлементСписка.Значение;
			Иначе
				Ограничение = Ограничение + ЭлементСписка.Представление;
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
	Если Не ПустаяСтрока(ПредставлениеОтбора) Тогда 
		ПредставлениеОтбора = ПредставлениеОтбора + "; ";
	КонецЕсли;
	
	ПредставлениеОтбора = ПредставлениеОтбора + Ограничение;
	
КонецПроцедуры

Функция ЖурналДляТехподдержки(ОтборЖурналаРегистрации, КоличествоСобытий, УникальныйИдентификатор = Неопределено) Экспорт
	
	Отбор = Новый Структура;
	Для Каждого ЭлементОтбора Из ОтборЖурналаРегистрации Цикл
		Отбор.Вставить(ЭлементОтбора.Ключ, ЭлементОтбора.Значение);
	КонецЦикла;
	СмещениеВремениСервера = СмещениеВремениСервера();
	ПреобразованиеОтбора(Отбор, СмещениеВремениСервера);
	
	// Выгрузка отбираемых событий и формирование структуры таблицы.
	ВременныйФайл = ПолучитьИмяВременногоФайла("xml");
	ВыгрузитьЖурналРегистрации(ВременныйФайл, Отбор, , , КоличествоСобытий);
	ДвоичныеДанные = Новый ДвоичныеДанные(ВременныйФайл);
	УдалитьФайлы(ВременныйФайл);
	
	Возврат ПоместитьВоВременноеХранилище(ДвоичныеДанные, УникальныйИдентификатор);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Вспомогательные процедуры и функции.

// Только для внутреннего использования.
//
Процедура УстановитьСтрокуАдресаДанных(СобытиеЖурнала)
	
	ЗаписьXML = Новый ЗаписьXML();
	ЗаписьXML.УстановитьСтроку();
	СериализаторXDTO.ЗаписатьXML(ЗаписьXML, СобытиеЖурнала.Данные); 
	СобытиеЖурнала.АдресДанных = ЗаписьXML.Закрыть();
	
КонецПроцедуры

Функция УровеньСобытияПоПредставлению(ПредставлениеУровня)
	Если ПредставлениеУровня = "Информация" Тогда
		Возврат УровеньЖурналаРегистрации.Информация;
	ИначеЕсли ПредставлениеУровня = "Ошибка" Тогда
		Возврат УровеньЖурналаРегистрации.Ошибка;
	ИначеЕсли ПредставлениеУровня = "Предупреждение" Тогда
		Возврат УровеньЖурналаРегистрации.Предупреждение; 
	ИначеЕсли ПредставлениеУровня = "Примечание" Тогда
		Возврат УровеньЖурналаРегистрации.Примечание;
	КонецЕсли;	
КонецФункции

#КонецОбласти
