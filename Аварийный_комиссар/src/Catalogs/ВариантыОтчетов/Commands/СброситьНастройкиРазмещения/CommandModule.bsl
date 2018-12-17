///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(Варианты, ПараметрыВыполненияКоманды)
	Если ТипЗнч(Варианты) <> Тип("Массив") Или Варианты.Количество() = 0 Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Выберите варианты отчетов программы, для которых необходимо сбросить настройки размещения.'"));
		Возврат;
	КонецЕсли;
	
	ОткрытьФорму("Справочник.ВариантыОтчетов.Форма.СбросНастроекРазмещения",
		Новый Структура("Варианты", Варианты), ПараметрыВыполненияКоманды.Источник);
КонецПроцедуры

#КонецОбласти
