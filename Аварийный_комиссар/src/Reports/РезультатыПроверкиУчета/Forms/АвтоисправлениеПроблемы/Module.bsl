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
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	ИдентификаторПроверки = Параметры.ИдентификаторПроверки;
	
	Если ИдентификаторПроверки = "СтандартныеПодсистемы.ПроверкаЦиклическихСсылок" Тогда
		ТекстВопроса = НСтр("ru = 'Исправление циклических ссылок может занять продолжительное время. Выполнить исправление?'");
	ИначеЕсли ИдентификаторПроверки = "СтандартныеПодсистемы.ПроверкаОтсутствующихПредопределенныхЭлементов" Тогда
		ТекстВопроса = НСтр("ru = 'Создать отсутствующие предопределенные элементы заново?'");
	КонецЕсли;
	
	Элементы.НадписьВопрос.Заголовок = ТекстВопроса;
	УстановитьТекущуюСтраницу(ЭтотОбъект, "Вопрос");
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ИсправитьПроблему(Команда)
	
	Если ИдентификаторПроверки = "СтандартныеПодсистемы.ПроверкаЦиклическихСсылок" Тогда
		ДлительнаяОперация = ИсправитьПроблемуВФоне(ИдентификаторПроверки);
		ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		ОповещениеОЗавершении = Новый ОписаниеОповещения("ИсправитьПроблемуВФонеЗавершение", ЭтотОбъект);
		ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);
	ИначеЕсли ИдентификаторПроверки = "СтандартныеПодсистемы.ПроверкаОтсутствующихПредопределенныхЭлементов" Тогда
		УстановитьТекущуюСтраницу(ЭтотОбъект, "ИдетИсправлениеПроблемы");
		ВосстановитьОтсутствующиеПредопределенныеЭлементы();
		УстановитьТекущуюСтраницу(ЭтотОбъект, "ИсправлениеУспешноВыполнено");
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьТекущуюСтраницу(Форма, ИмяСтраницы)
	
	ЭлементыФормы = Форма.Элементы;
	Если ИмяСтраницы = "ИдетИсправлениеПроблемы" Тогда
		ЭлементыФормы.ГруппаИндикаторИсправления.Видимость         = Истина;
		ЭлементыФормы.ГруппаИндикаторНачалаИсправления.Видимость   = Ложь;
		ЭлементыФормы.ГруппаИндикаторУспешноеИсправление.Видимость = Ложь;
	ИначеЕсли ИмяСтраницы = "ИсправлениеУспешноВыполнено" Тогда
		ЭлементыФормы.ГруппаИндикаторИсправления.Видимость         = Ложь;
		ЭлементыФормы.ГруппаИндикаторНачалаИсправления.Видимость   = Ложь;
		ЭлементыФормы.ГруппаИндикаторУспешноеИсправление.Видимость = Истина;
	Иначе // "Вопрос"
		ЭлементыФормы.ГруппаИндикаторИсправления.Видимость         = Ложь;
		ЭлементыФормы.ГруппаИндикаторНачалаИсправления.Видимость   = Истина;
		ЭлементыФормы.ГруппаИндикаторУспешноеИсправление.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ИсправитьПроблемуВФоне(ИдентификаторПроверки)
	
	Если ДлительнаяОперация <> Неопределено Тогда
		ДлительныеОперации.ОтменитьВыполнениеЗадания(ДлительнаяОперация.ИдентификаторЗадания);
	КонецЕсли;
	
	УстановитьТекущуюСтраницу(ЭтотОбъект, "ИдетИсправлениеПроблемы");
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Исправление циклических ссылок'");
	
	Возврат ДлительныеОперации.ВыполнитьВФоне("КонтрольВеденияУчетаСлужебный.ИсправитьПроблемуЦиклическихСсылокВФоновомЗадании",
		Новый Структура("ИдентификаторПроверки", ИдентификаторПроверки), ПараметрыВыполнения);
	
КонецФункции

&НаКлиенте
Процедура ИсправитьПроблемуВФонеЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ДлительнаяОперация = Неопределено;

	Если Результат = Неопределено Тогда
		УстановитьТекущуюСтраницу(ЭтотОбъект, "ИдетИсправлениеПроблемы");
		Возврат;
	ИначеЕсли Результат.Статус = "Ошибка" Тогда
		УстановитьТекущуюСтраницу(ЭтотОбъект, "Вопрос");
		ВызватьИсключение Результат.КраткоеПредставлениеОшибки;
	ИначеЕсли Результат.Статус = "Выполнено" Тогда
		УстановитьТекущуюСтраницу(ЭтотОбъект, "ИсправлениеУспешноВыполнено");
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ВосстановитьОтсутствующиеПредопределенныеЭлементы() 
	
	СтандартныеПодсистемыСервер.ВосстановитьПредопределенныеЭлементы();
	
КонецПроцедуры

#КонецОбласти