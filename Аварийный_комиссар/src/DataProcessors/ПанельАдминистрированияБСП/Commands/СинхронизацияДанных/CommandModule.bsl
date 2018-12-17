///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Если СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиента().ДоступноИспользованиеРазделенныхДанных Тогда
		ИмяОткрываемойФормы = "Обработка.ПанельАдминистрированияБСП.Форма.СинхронизацияДанных";
	Иначе
		ИмяОткрываемойФормы = "Обработка.ПанельАдминистрированияБСПВМоделиСервиса.Форма.СинхронизацияДанныхДляАдминистратораСервиса";
	КонецЕсли;
	
	ОткрытьФорму(
		ИмяОткрываемойФормы,
		Новый Структура,
		ПараметрыВыполненияКоманды.Источник,
		ИмяОткрываемойФормы + ?(ПараметрыВыполненияКоманды.Окно = Неопределено, ".ОтдельноеОкно", ""),
		ПараметрыВыполненияКоманды.Окно);
	
КонецПроцедуры

#КонецОбласти
