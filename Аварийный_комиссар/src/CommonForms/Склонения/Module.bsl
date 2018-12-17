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
	
	Если Параметры.Свойство("Склонения") И Параметры.Склонения <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, Параметры.Склонения);
		Склонения = Параметры.Склонения;
	КонецЕсли;
	
	Если Параметры.Свойство("ЭтоФИО") Тогда
		ЭтоФИО = Параметры.ЭтоФИО;
	КонецЕсли;
	
	Если Параметры.Свойство("Пол") Тогда
		Пол = Параметры.Пол;
	КонецЕсли;
	
	Если Параметры.Свойство("Представление") Тогда
		Представление = Параметры.Представление;
	КонецЕсли;
	
	Если Параметры.Свойство("ИзмененоПредставление") Тогда
		ИзмененоПредставление = Параметры.ИзмененоПредставление;		
	КонецЕсли;   
		
	ОбновитьГруппуИнформационнаяНадписьСервисСклонения();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ДлительнаяОперация = ПросклонятьПредставлениеПоВсемПадежам();
	
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);

	ОповещениеОЗавершении = Новый ОписаниеОповещения("ПросклонятьПредставлениеПоВсемПадежамЗавершение", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаОтмена(Команда)
	
	Закрыть(Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаОК(Команда)
	
	СтруктураСклонения = СклонениеПредставленийОбъектовКлиентСервер.СтруктураСклонения();
	ЗаполнитьЗначенияСвойств(СтруктураСклонения, ЭтотОбъект);	
				
	Закрыть(СтруктураСклонения);
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПросклонятьПовторно(Команда)
	
	ПросклонятьПовторноНаСервере();	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПросклонятьПредставлениеПоВсемПадежам()
	
	ПараметрыПроцедуры = Новый Структура;
	ПараметрыПроцедуры.Вставить("Представление", Представление);
	ПараметрыПроцедуры.Вставить("ЭтоФИО", ЭтоФИО);
	ПараметрыПроцедуры.Вставить("Пол", Пол);
	ПараметрыПроцедуры.Вставить("ИзмененоПредставление", ИзмененоПредставление);
	ПараметрыПроцедуры.Вставить("Склонения", Склонения);
		
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Склонение представления'");
	
	Возврат ДлительныеОперации.ВыполнитьВФоне("СклонениеПредставленийОбъектов.ПросклонятьПредставлениеПоВсемПадежамДлительнаяОперация", 
		ПараметрыПроцедуры, ПараметрыВыполнения);   	
	
КонецФункции

&НаКлиенте
Процедура ПросклонятьПредставлениеПоВсемПадежамЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	СтруктураСклонений = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
	
	Если ТипЗнч(СтруктураСклонений) = Тип("Структура") Тогда
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, СтруктураСклонений);
		Склонения = Новый ФиксированнаяСтруктура(СтруктураСклонений);
	КонецЕсли;
	
	ОбновитьГруппуИнформационнаяНадписьСервисСклонения();
	
КонецПроцедуры 

&НаСервере
Процедура ОбновитьГруппуИнформационнаяНадписьСервисСклонения()
	
	Элементы.ГруппаИнформационнаяНадписьСервисСклонения.Видимость = Ложь;
	
	Если ЭтоФИО Тогда
		Возврат;
	КонецЕсли;
	
	ИспользоватьСервисСклонения = Константы.ИспользоватьСервисСклоненияMorpher.Получить();
	
	Если Не ИспользоватьСервисСклонения Тогда
		Элементы.ГруппаИнформационнаяНадписьСервисСклонения.Видимость = Истина;
		Элементы.ГруппаИнформационнаяНадписьСервисСклонения.ТекущаяСтраница = Элементы.ГруппаИнформационнаяНадписьВключениеСервиса;
		Возврат;
	КонецЕсли;
	
	Если Не СклонениеПредставленийОбъектов.ДоступенСервисСклонения() Тогда
		Элементы.ГруппаИнформационнаяНадписьСервисСклонения.Видимость = Истина;
		Элементы.ГруппаИнформационнаяНадписьСервисСклонения.ТекущаяСтраница = Элементы.ГруппаИнформационнаяНадписьДоступностьСервиса;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПросклонятьПовторноНаСервере()
	
	СклонениеПредставленийОбъектов.УстановитьДоступностьСервисаСклонения(Истина);
	
	ИзмененоПредставление = Истина;
	СтруктураСклонения = СклонениеПредставленийОбъектов.ДанныеСклонения(Представление, ЭтоФИО, Пол, Истина);
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, СтруктураСклонения);
	Склонения = Новый ФиксированнаяСтруктура(СтруктураСклонения);	
	ИзмененоПредставление = Ложь;
	
	ОбновитьГруппуИнформационнаяНадписьСервисСклонения();
	
КонецПроцедуры

#КонецОбласти

