///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	НастройкиПодсистемы  = ОбновлениеИнформационнойБазыСлужебный.НастройкиПодсистемы();
	АдресФормыВПрограмме = НастройкиПодсистемы.РасположениеОписанияИзмененийПрограммы;
	
	Если ЗначениеЗаполнено(АдресФормыВПрограмме) Тогда
		Элементы.АдресФормыВПрограмме.Заголовок = АдресФормыВПрограмме;
	КонецЕсли;
	
	Если Не Параметры.ПоказыватьТолькоИзменения Тогда
		Элементы.АдресФормыВПрограмме.Видимость = Ложь;
	КонецЕсли;
	
	Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Что нового в конфигурации %1'"), Метаданные.Синоним);
	
	Если ЗначениеЗаполнено(Параметры.ВремяНачалаОбновления) Тогда
		ВремяНачалаОбновления = Параметры.ВремяНачалаОбновления;
		ВремяОкончанияОбновления = Параметры.ВремяОкончанияОбновления;
	КонецЕсли;
	
	Разделы = ОбновлениеИнформационнойБазыСлужебный.НеотображавшиесяРазделыОписанияИзменений();
	ПоследняяВерсия = ОбновлениеИнформационнойБазыСлужебный.ПоследняяВерсияОтображенияИзмененийСистемы();
	
	Если Разделы.Количество() = 0 Тогда
		ДокументОписаниеОбновлений = Метаданные.ОбщиеМакеты.Найти("ОписаниеИзмененийСистемы");
		Если ДокументОписаниеОбновлений <> Неопределено
			И (ПоследняяВерсия = Неопределено
				Или Не Параметры.ПоказыватьТолькоИзменения) Тогда
			ВсеРазделы = ОбновлениеИнформационнойБазыСлужебный.РазделыОписанияИзменений();
			Если ТипЗнч(ВсеРазделы) = Тип("СписокЗначений")
				И ВсеРазделы.Количество() <> 0 Тогда
				Для Каждого Элемент Из ВсеРазделы Цикл
					Разделы.Добавить(Элемент.Представление);
				КонецЦикла;
				ДокументОписаниеОбновлений = ОбновлениеИнформационнойБазыСлужебный.ДокументОписаниеОбновлений(Разделы);
			Иначе
				ДокументОписаниеОбновлений = ПолучитьОбщийМакет(ДокументОписаниеОбновлений);
			КонецЕсли;
		Иначе
			ДокументОписаниеОбновлений = Новый ТабличныйДокумент();
		КонецЕсли;
	Иначе
		ДокументОписаниеОбновлений = ОбновлениеИнформационнойБазыСлужебный.ДокументОписаниеОбновлений(Разделы);
	КонецЕсли;
	
	Если ДокументОписаниеОбновлений.ВысотаТаблицы = 0 Тогда
		Текст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Конфигурация успешно обновлена на версию %1'"), Метаданные.Версия);
		ДокументОписаниеОбновлений.Область("R1C1:R1C1").Текст = Текст;
	КонецЕсли;
	
	ОписанияПодсистем  = СтандартныеПодсистемыПовтИсп.ОписанияПодсистем();
	Для каждого ИмяПодсистемы Из ОписанияПодсистем.Порядок Цикл
		ОписаниеПодсистемы = ОписанияПодсистем.ПоИменам.Получить(ИмяПодсистемы);
		Если НЕ ЗначениеЗаполнено(ОписаниеПодсистемы.ОсновнойСерверныйМодуль) Тогда
			Продолжить;
		КонецЕсли;
		Модуль = ОбщегоНазначения.ОбщийМодуль(ОписаниеПодсистемы.ОсновнойСерверныйМодуль);
		Модуль.ПриПодготовкеМакетаОписанияОбновлений(ДокументОписаниеОбновлений);
	КонецЦикла;
	ОбновлениеИнформационнойБазыПереопределяемый.ПриПодготовкеМакетаОписанияОбновлений(ДокументОписаниеОбновлений);
	
	ОписаниеОбновлений.Очистить();
	ОписаниеОбновлений.Вывести(ДокументОписаниеОбновлений);
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	ВремяНачалаОбновления = СведенияОбОбновлении.ВремяНачалаОбновления;
	ВремяОкончанияОбновления = СведенияОбОбновлении.ВремяОкончанияОбновления;
	
	Если Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных()
		Или СведенияОбОбновлении.ОтложенноеОбновлениеЗавершеноУспешно <> Неопределено
		Или СведенияОбОбновлении.ДеревоОбработчиков <> Неопределено
			И СведенияОбОбновлении.ДеревоОбработчиков.Строки.Количество() = 0 Тогда
		Элементы.ОтложенноеОбновление.Видимость = Ложь;
	КонецЕсли;
	
	Если ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		ЗаголовокСообщения = НСтр("ru = 'Необходимо выполнить дополнительные процедуры обработки данных'");
		Элементы.ОтложенноеОбновлениеДанных.Заголовок = ЗаголовокСообщения;
	КонецЕсли;
	
	Если Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		Элементы.ОтложенноеОбновлениеДанных.Заголовок =
			НСтр("ru = 'Не выполнены дополнительные процедуры обработки данных'");
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ВремяНачалаОбновления) И Не ЗначениеЗаполнено(ВремяОкончанияОбновления) Тогда
		Элементы.ТехническаяИнформацияОРезультатахОбновления.Видимость = Ложь;
	ИначеЕсли Пользователи.ЭтоПолноправныйПользователь() И Не ОбщегоНазначения.РазделениеВключено() Тогда
		Элементы.ТехническаяИнформацияОРезультатахОбновления.Видимость = Истина;
	Иначе
		Элементы.ТехническаяИнформацияОРезультатахОбновления.Видимость = Ложь;
	КонецЕсли;
	
	КлиентСервернаяБаза = Не ОбщегоНазначения.ИнформационнаяБазаФайловая();
	
	// Отображение информации о блокировке регламентных заданий.
	Если Не КлиентСервернаяБаза
		И Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		ПараметрЗапускаКлиента = ПараметрыСеанса.ПараметрыКлиентаНаСервере.Получить("ПараметрЗапуска");
		ВыполненоОтключениеРегламентныхЗаданий = СтрНайти(ПараметрЗапускаКлиента, "РегламентныеЗаданияОтключены") <> 0;
		Если Не ВыполненоОтключениеРегламентныхЗаданий Тогда
			Элементы.ГруппаОтключеныРегламентныеЗадания.Видимость = Ложь;
		КонецЕсли;
	Иначе
		Элементы.ГруппаОтключеныРегламентныеЗадания.Видимость = Ложь;
	КонецЕсли;
	
	Элементы.ОписаниеОбновлений.ГоризонтальнаяПолосаПрокрутки = ИспользованиеПолосыПрокрутки.НеИспользовать;
	
	ОбновлениеИнформационнойБазыСлужебный.УстановитьФлагОтображенияОписанийПоТекущуюВерсию();
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		Элементы.КоманднаяПанельФормы.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если КлиентСервернаяБаза Тогда
		ПодключитьОбработчикОжидания("ОбновитьСтатусОтложенногоОбновления", 60);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОписаниеОбновленийВыбор(Элемент, Область, СтандартнаяОбработка)
	
	Если СтрНайти(Область.Текст, "http://") = 1 Или СтрНайти(Область.Текст, "https://") = 1 Тогда
		ФайловаяСистемаКлиент.ОткрытьНавигационнуюСсылку(Область.Текст);
	КонецЕсли;
	
	ОбновлениеИнформационнойБазыКлиентПереопределяемый.ПриНажатииНаГиперссылкуВДокументеОписанияОбновлений(Область);
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьСведенияОРезультатахОбновленияНажатие(Элемент)
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПоказатьОшибкиИПредупреждения", Истина);
	ПараметрыФормы.Вставить("ДатаНачала", ВремяНачалаОбновления);
	ПараметрыФормы.Вставить("ДатаОкончания", ВремяОкончанияОбновления);
	
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", ПараметрыФормы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОтложенноеОбновлениеДанных(Команда)
	ОткрытьФорму("Обработка.РезультатыОбновленияПрограммы.Форма.ИндикацияХодаОтложенногоОбновленияИБ");
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОбновитьСтатусОтложенногоОбновления()
	
	ОбновитьСтатусОтложенногоОбновленияНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСтатусОтложенногоОбновленияНаСервере()
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	Если СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления <> Неопределено Тогда
		Элементы.ОтложенноеОбновление.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтключеныРегламентныеЗаданияОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	Оповещение = Новый ОписаниеОповещения("ОтключеныРегламентныеЗаданияОбработкаНавигационнойСсылкиЗавершение", ЭтотОбъект);
	ТекстВопроса = НСтр("ru = 'Перезапустить программу?'");
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Нет);
КонецПроцедуры

&НаКлиенте
Процедура ОтключеныРегламентныеЗаданияОбработкаНавигационнойСсылкиЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		НовыйПараметрЗапуска = СтрЗаменить(ПараметрЗапуска, "РегламентныеЗаданияОтключены", "");
		НовыйПараметрЗапуска = СтрЗаменить(НовыйПараметрЗапуска, "ЗапуститьОбновлениеИнформационнойБазы", "");
		НовыйПараметрЗапуска = "/C """ + НовыйПараметрЗапуска + """";
		ПрекратитьРаботуСистемы(Истина, НовыйПараметрЗапуска);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
