///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Запрашивает у пользователя диалог с подтверждением легальности полученного
// обновления и завершает работу системы, если обновление получено не легально
// (см. параметр ЗавершатьРаботуСистемы).
//
// Параметры:
//  Оповещение             - ОписаниеОповещения - содержит обработчик, вызываемый после
//                                    подтверждения легальности получения обновления.
//  ЗавершатьРаботуСистемы - Булево - завершать работу системы, если пользователь
//                                    указал что обновление получено не легально.
//
Процедура ПоказатьПроверкуЛегальностиПолученияОбновления(Оповещение, ЗавершатьРаботуСистемы = Ложь) Экспорт
	
	Если СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиента().ЭтоБазоваяВерсияКонфигурации Тогда
		ВыполнитьОбработкуОповещения(Оповещение, Истина);
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПоказыватьПредупреждениеОПерезапуске", ЗавершатьРаботуСистемы);
	ПараметрыФормы.Вставить("ПрограммноеОткрытие", Истина);
	
	ОткрытьФорму("Обработка.ЛегальностьПолученияОбновлений.Форма", ПараметрыФормы,,,,, Оповещение);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// См. ОбщегоНазначенияКлиентПереопределяемый.ПередНачаломРаботыСистемы.
Процедура ПередНачаломРаботыСистемы(Параметры) Экспорт
	
	// Проверить легальность получения обновления при запуске программы.
	// Процедура должна вызываться перед обновлением информационной базы.
	
	ПараметрыКлиента = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске();
	
	Если Не ПараметрыКлиента.Свойство("ПроверитьЛегальностьПолученияОбновления") Тогда
		Возврат;
	КонецЕсли;
	
	Параметры.ИнтерактивнаяОбработка = Новый ОписаниеОповещения(
		"ИнтерактивнаяОбработкаПроверкиЛегальностиПолученияОбновления", ЭтотОбъект);
	
КонецПроцедуры

// Только для внутреннего использования. Продолжение процедуры ПроверитьЛегальностьПолученияОбновленияПриЗапуске.
Процедура ИнтерактивнаяОбработкаПроверкиЛегальностиПолученияОбновления(Параметры, Контекст) Экспорт
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПрограммноеОткрытие", Истина);
	ПараметрыФормы.Вставить("ПоказыватьПредупреждениеОПерезапуске", Истина);
	ПараметрыФормы.Вставить("ПропуститьПерезапуск", Истина);
	
	ОткрытьФорму("Обработка.ЛегальностьПолученияОбновлений.Форма", ПараметрыФормы, , , , ,
		Новый ОписаниеОповещения("ПослеЗакрытияФормыПроверкиЛегальностиПолученияОбновленияПриЗапуске",
			ЭтотОбъект, Параметры));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Только для внутреннего использования. Продолжение процедуры ПроверитьЛегальностьПолученияОбновленияПриЗапуске.
Процедура ПослеЗакрытияФормыПроверкиЛегальностиПолученияОбновленияПриЗапуске(Результат, Параметры) Экспорт
	
	Если Результат <> Истина Тогда
		Параметры.Отказ = Истина;
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(Параметры.ОбработкаПродолжения);
	
КонецПроцедуры

#КонецОбласти
