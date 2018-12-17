///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Функция КэшФормы(Знач ИмяФормы, Знач ИсточникиЧерезЗапятую, Знач ЭтоФормаОбъекта) Экспорт
	Возврат Новый ФиксированнаяСтруктура(ПодключаемыеКоманды.КэшФормы(ИмяФормы, ИсточникиЧерезЗапятую, ЭтоФормаОбъекта));
КонецФункции

Функция Параметры() Экспорт
	
	УстановитьОтключениеБезопасногоРежима(Истина);
	УстановитьПривилегированныйРежим(Истина);
	
	Параметры = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы("СтандартныеПодсистемы.ПодключаемыеКоманды");
	Если Параметры = Неопределено Тогда
		ПодключаемыеКоманды.ОперативноеОбновлениеОбщихДанныхКонфигурации();
		Параметры = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы("СтандартныеПодсистемы.ПодключаемыеКоманды");
		Если Параметры = Неопределено Тогда
			Возврат Новый ФиксированнаяСтруктура("ПодключенныеОбъекты", Новый Соответствие);
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрыСеанса.ВерсияРасширений) Тогда
		ПараметрыРасширений = СтандартныеПодсистемыСервер.ПараметрРаботыРасширения(ПодключаемыеКоманды.ПолноеИмяПодсистемы());
		Если ПараметрыРасширений = Неопределено Тогда
			ПодключаемыеКоманды.ПриЗаполненииВсехПараметровРаботыРасширений();
			ПараметрыРасширений = СтандартныеПодсистемыСервер.ПараметрРаботыРасширения(ПодключаемыеКоманды.ПолноеИмяПодсистемы());
			Если ПараметрыРасширений = Неопределено Тогда
				Возврат Новый ФиксированнаяСтруктура(Параметры);
			КонецЕсли;
		КонецЕсли;
		ДополнитьСоответствиеСМассивами(Параметры.ПодключенныеОбъекты, ПараметрыРасширений.ПодключенныеОбъекты);
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Ложь);
	УстановитьОтключениеБезопасногоРежима(Ложь);
	
	Возврат Новый ФиксированнаяСтруктура(Параметры);
КонецФункции

Процедура ДополнитьСоответствиеСМассивами(СоответствиеПриемник, СоответствиеИсточник)
	Для Каждого КлючИЗначение Из СоответствиеИсточник Цикл
		МассивПриемника = СоответствиеПриемник[КлючИЗначение.Ключ];
		Если МассивПриемника = Неопределено Тогда
			СоответствиеПриемник[КлючИЗначение.Ключ] = КлючИЗначение.Значение;
		Иначе
			ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивПриемника, КлючИЗначение.Значение, Истина);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти
