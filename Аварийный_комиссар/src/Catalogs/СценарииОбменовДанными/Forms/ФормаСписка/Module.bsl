///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВключитьОтключитьРегламентноеЗадание(Команда)
	
	ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
	
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	ВключитьОтключитьРегламентноеЗаданиеНаСервере(ВыделенныеСтроки, Не ТекущиеДанные.ИспользоватьРегламентноеЗадание);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ВключитьОтключитьРегламентноеЗаданиеНаСервере(ВыделенныеСтроки, ИспользоватьРегламентноеЗадание)
	
	Для Каждого ДанныеСтроки Из ВыделенныеСтроки Цикл
		
		Если ДанныеСтроки.ПометкаУдаления Тогда
			Продолжить;
		КонецЕсли;
		
		НастройкаОбъект = ДанныеСтроки.Ссылка.ПолучитьОбъект();
		НастройкаОбъект.ИспользоватьРегламентноеЗадание = ИспользоватьРегламентноеЗадание;
		НастройкаОбъект.Записать();
		
	КонецЦикла;
	
	// обновляем данные списка
	Элементы.Список.Обновить();
	
КонецПроцедуры

#КонецОбласти
