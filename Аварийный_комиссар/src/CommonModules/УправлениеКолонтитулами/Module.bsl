///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// УправлениеКолонтитулами: механизм настройки и вывода колонтитулов.
//
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Получает сохраненные ранее настройки колонтитулов. Если настройки отсутствуют, то
// возвращается пустая структура настроек.
//
// Возвращаемое значение:
//   Структура - значения настроек колонтитулов.
Функция НастройкиКолонтитулов() Экспорт
	Перем Настройки;
	
	Хранилище = Константы.НастройкиКолонтитулов.Получить();
	Если ТипЗнч(Хранилище) = Тип("ХранилищеЗначения") Тогда
		Настройки = Хранилище.Получить();
		Если ТипЗнч(Настройки) = Тип("Структура") Тогда
			Если Не Настройки.Свойство("ВерхнийКолонтитул") 
				Или Не Настройки.Свойство("НижнийКолонтитул") Тогда
				Настройки = Неопределено;
			Иначе
				ДополнитьНастройкиКолонтитула(Настройки.ВерхнийКолонтитул);
				ДополнитьНастройкиКолонтитула(Настройки.НижнийКолонтитул);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если Настройки = Неопределено Тогда
		Настройки = ПустыеНастройкиКолонтитулов();
	КонецЕсли;
	
	Возврат Настройки;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Сохраняет переданные в параметре настройки колонтитулов для дальнейшего использования.
//
// Параметры:
//  Настройки - Структура - значения настроек колонтитулов, которые необходимо сохранить.
//
Процедура СохранитьНастройкиКолонтитулов(Настройки) Экспорт
	Константы.НастройкиКолонтитулов.Установить(Новый ХранилищеЗначения(Настройки));
КонецПроцедуры

// Устанавливает значения параметров НазваниеОтчета и Пользователь в строке шаблона.
//
//  Шаблон - Строка - настройка колонтитула с еще не установленными значениями параметров.
//  НазваниеОтчета - Строка - значение параметра, которое будет подставлено в шаблон.
//  Пользователь - СправочникСсылка.Пользователи - значение параметра, которое будет подставлено в шаблон.
//
// Возвращаемое значение:
//   Строка - настройка колонтитула с установленными значениями шаблона.
//
Функция ЗначениеСвойстваПоШаблону(Шаблон, НазваниеОтчета, Пользователь)
	Результат = СтрЗаменить(Шаблон, "[&НазваниеОтчета]", СокрЛП(НазваниеОтчета));
	Результат = СтрЗаменить(Результат, "[&Пользователь]"  , СокрЛП(Пользователь));
	
	Возврат Результат;
КонецФункции

// Устанавливает колонтитулы в табличном документе.
//
// Параметры:
//  ТабличныйДокумент - ТабличныйДокумент - документ, в котором надо установить колонтитулы.
//  НазваниеОтчета - Строка - значение параметра, которое будет подставлено в шаблон.
//  Пользователь - СправочникСсылка.Пользователи - значение параметра, которое будет подставлено в шаблон.
//  НастройкиКолонтитулов - Структура - индивидуальные настройки колонтитулов.
//
Процедура УстановитьКолонтитулы(ТабличныйДокумент, НазваниеОтчета = "", Пользователь = Неопределено, НастройкиКолонтитулов = Неопределено) Экспорт
	Если Пользователь = Неопределено Тогда
		Пользователь = Пользователи.АвторизованныйПользователь();
	КонецЕсли;
	
	Если НастройкиКолонтитулов = Неопределено Тогда 
		НастройкиКолонтитулов = НастройкиКолонтитулов();
	КонецЕсли;
	
	СвойстваКолонтитула = СвойстваКолонтитула(НастройкиКолонтитулов.ВерхнийКолонтитул, НазваниеОтчета, Пользователь);
	ЗаполнитьЗначенияСвойств(ТабличныйДокумент.ВерхнийКолонтитул, СвойстваКолонтитула);
	
	СвойстваКолонтитула = СвойстваКолонтитула(НастройкиКолонтитулов.НижнийКолонтитул, НазваниеОтчета, Пользователь);
	ЗаполнитьЗначенияСвойств(ТабличныйДокумент.НижнийКолонтитул, СвойстваКолонтитула);
КонецПроцедуры

// Возвращает значения свойств колонтитула.
//
// Параметры:
//  НастройкиКолонтитула - Структура - см. ПустыеНастройкиКолонтитулов().
//  НазваниеОтчета - Строка - значение, которое будет подставлено в шаблон [&НазваниеОтчета].
//  Пользователь - СправочникСсылка.Пользователи - значение, которое будет подставлено в шаблон [&Пользователь].
//
// Возвращаемое значение:
//   Структура - значения настроек колонтитулов.
//
Функция СвойстваКолонтитула(НастройкиКолонтитула, НазваниеОтчета, Пользователь)
	СвойстваКолонтитула = Новый Структура;
	Если ЗначениеЗаполнено(НастройкиКолонтитула.ТекстСлева)
		Или ЗначениеЗаполнено(НастройкиКолонтитула.ТекстВЦентре)
		Или ЗначениеЗаполнено(НастройкиКолонтитула.ТекстСправа) Тогда
		
		СвойстваКолонтитула.Вставить("Выводить", Истина);
		СвойстваКолонтитула.Вставить("НачальнаяСтраница", НастройкиКолонтитула.НачальнаяСтраница);
		СвойстваКолонтитула.Вставить("ВертикальноеПоложение", НастройкиКолонтитула.ВертикальноеПоложение);
		СвойстваКолонтитула.Вставить("ТекстСлева", ЗначениеСвойстваПоШаблону(
			НастройкиКолонтитула.ТекстСлева, НазваниеОтчета, Пользователь));
		СвойстваКолонтитула.Вставить("ТекстВЦентре", ЗначениеСвойстваПоШаблону(
			НастройкиКолонтитула.ТекстВЦентре, НазваниеОтчета, Пользователь));
		СвойстваКолонтитула.Вставить("ТекстСправа", ЗначениеСвойстваПоШаблону(
			НастройкиКолонтитула.ТекстСправа, НазваниеОтчета, Пользователь));
		
		Если НастройкиКолонтитула.Свойство("Шрифт") И НастройкиКолонтитула.Шрифт <> Неопределено Тогда
			СвойстваКолонтитула.Вставить("Шрифт", НастройкиКолонтитула.Шрифт);
		Иначе
			СвойстваКолонтитула.Вставить("Шрифт", Новый Шрифт);
		КонецЕсли;
	Иначе
		СвойстваКолонтитула.Вставить("Выводить", Ложь);
	КонецЕсли;
	
	Возврат СвойстваКолонтитула;
КонецФункции

// Конструктор настроек колонтитулов.
//
// Возвращаемое значение:
//   Структура - настройки колонтитулов со значениями по умолчанию.
//
Функция ПустыеНастройкиКолонтитулов()
	ВерхнийКолонтитул = Новый Структура;
	ВерхнийКолонтитул.Вставить("ТекстСлева", "");
	ВерхнийКолонтитул.Вставить("ТекстВЦентре", "");
	ВерхнийКолонтитул.Вставить("ТекстСправа", "");
	ВерхнийКолонтитул.Вставить("Шрифт", Новый Шрифт);
	ВерхнийКолонтитул.Вставить("ВертикальноеПоложение", ВертикальноеПоложение.Низ);
	ВерхнийКолонтитул.Вставить("НачальнаяСтраница", 0);
	
	НижнийКолонтитул = Новый Структура;
	НижнийКолонтитул.Вставить("ТекстСлева", "");
	НижнийКолонтитул.Вставить("ТекстВЦентре", "");
	НижнийКолонтитул.Вставить("ТекстСправа", "");
	НижнийКолонтитул.Вставить("Шрифт", Новый Шрифт);
	НижнийКолонтитул.Вставить("ВертикальноеПоложение", ВертикальноеПоложение.Верх);
	НижнийКолонтитул.Вставить("НачальнаяСтраница", 0);
	
	Возврат Новый Структура("ВерхнийКолонтитул, НижнийКолонтитул", ВерхнийКолонтитул, НижнийКолонтитул);
КонецФункции

Процедура ДополнитьНастройкиКолонтитула(НастройкиКолонтитула)
	Если Не НастройкиКолонтитула.Свойство("ТекстСлева")
		Или ТипЗнч(НастройкиКолонтитула.ТекстСлева) <> Тип("Строка") Тогда
		НастройкиКолонтитула.Вставить("ТекстСлева", "");
	КонецЕсли;
	Если Не НастройкиКолонтитула.Свойство("ТекстВЦентре")
		Или ТипЗнч(НастройкиКолонтитула.ТекстВЦентре) <> Тип("Строка") Тогда
		НастройкиКолонтитула.Вставить("ТекстВЦентре", "");
	КонецЕсли;
	Если Не НастройкиКолонтитула.Свойство("ТекстСправа")
		Или ТипЗнч(НастройкиКолонтитула.ТекстСправа) <> Тип("Строка") Тогда
		НастройкиКолонтитула.Вставить("ТекстСправа", "");
	КонецЕсли;
	Если Не НастройкиКолонтитула.Свойство("Шрифт")
		Или ТипЗнч(НастройкиКолонтитула.Шрифт) <> Тип("Шрифт") Тогда
		НастройкиКолонтитула.Вставить("Шрифт", Новый Шрифт);
	КонецЕсли;
	Если Не НастройкиКолонтитула.Свойство("ВертикальноеПоложение")
		Или ТипЗнч(НастройкиКолонтитула.ВертикальноеПоложение) <> Тип("ВертикальноеПоложение") Тогда
		НастройкиКолонтитула.Вставить("ВертикальноеПоложение", ВертикальноеПоложение.Центр);
	КонецЕсли;
	Если Не НастройкиКолонтитула.Свойство("НачальнаяСтраница")
		Или ТипЗнч(НастройкиКолонтитула.НачальнаяСтраница) <> Тип("Число")
		Или НастройкиКолонтитула.НачальнаяСтраница < 0 Тогда
		НастройкиКолонтитула.Вставить("НачальнаяСтраница", 0);
	КонецЕсли;
КонецПроцедуры

// Определяет не являются ли настройки стандартными и/или пустыми.
//
// Параметры:
//  Настройки - Структура - см. НастройкиКолонтитулов().
//
// Возвращаемое значение:
//   Структура - сведения о состоянии настроек колонтитулов:
//     * Стандартные - Булево - Истина, если переданные настройки соответствуют стандартным (общим)
//                     настройкам, хранящимся в константе НастройкиКолонтитулов.
//     * Пустые - Булево - Истина, если переданные настройки соответствуют пустым,
//                возвращенным функцией ПустыеНастройкиКолонтитулов().
//
Функция СтатусНастроекКолонтитулов(Настройки) Экспорт 
	СтатусНастроек = Новый Структура("Стандартные, Пустые");
	СтатусНастроек.Стандартные = ОбщегоНазначения.ДанныеСовпадают(Настройки, НастройкиКолонтитулов());
	СтатусНастроек.Пустые = ОбщегоНазначения.ДанныеСовпадают(Настройки, ПустыеНастройкиКолонтитулов());
	
	Возврат СтатусНастроек;
КонецФункции

#КонецОбласти