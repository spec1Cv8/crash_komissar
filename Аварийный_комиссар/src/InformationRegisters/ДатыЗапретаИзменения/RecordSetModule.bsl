///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Отбор.Пользователь.Использование
	   И Не ДатыЗапретаИзмененияСлужебный.ЭтоАдресатЗапретаИзменения(Отбор.Пользователь.Значение) Тогда
		// Даты запрета загрузки настраиваются отдельно в каждой информационной базе.
		ДополнительныеСвойства.Вставить("ОтключитьМеханизмРегистрацииОбъектов");
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ, Замещение)
	
	// В режиме ОбменДанными.Загрузка необходимо обновлять УИД в константе ВерсияДатЗапретаИзменения,
	// который позволять сеансам определить, что нужно обновить кэш дат запрета изменения в памяти.
	Если ОбменДанными.Загрузка Тогда
		Если Не ДополнительныеСвойства.Свойство("ПропуститьОбновлениеВерсииДатЗапретаИзменения") Тогда
			ДатыЗапретаИзмененияСлужебный.ОбновитьВерсиюДатЗапретаИзмененияПриЗагрузкеДанных(ЭтотОбъект);
		КонецЕсли;
		Возврат;
	КонецЕсли;
	
	Если Не ДополнительныеСвойства.Свойство("ПропуститьОбновлениеВерсииДатЗапретаИзменения") Тогда
		ДатыЗапретаИзмененияСлужебный.ОбновитьВерсиюДатЗапретаИзменения();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли