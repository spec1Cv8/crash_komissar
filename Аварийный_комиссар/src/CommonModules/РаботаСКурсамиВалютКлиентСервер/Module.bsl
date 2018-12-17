///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Пересчитывает сумму из текущей валюты в новую валюту по параметрам их курсов. 
// Параметры курсов валют можно получить функцией РаботаСКурсамиВалют.ПолучитьКурсВалюты.
//
// Параметры:
//   Сумма                  - Число     - сумма, которую следует пересчитать.
//
//   ПараметрыТекущегоКурса - Структура - параметры курса валюты, из которой надо пересчитать.
//    * Валюта    - СправочникСсылка.Валюты - ссылка пересчитываемой валюты.
//    * Курс      - Число - курс пересчитываемой валюты.
//    * Кратность - Число - кратность пересчитываемой валюты.
//
//   ПараметрыНовогоКурса   - Структура - параметры курса валюты, в  которую надо пересчитать.
//    * Валюта    - СправочникСсылка.Валюты - ссылка валюты, в которую идет пересчет.
//    * Курс      - Число - курс валюты, в которую идет пересчет.
//    * Кратность - Число - кратность валюты, в которую идет пересчет.
//
// Возвращаемое значение: 
//   Число - Сумма, пересчитанная по новому курсу.
//
Функция ПересчитатьПоКурсу(Сумма, ПараметрыТекущегоКурса, ПараметрыНовогоКурса) Экспорт
	Если ПараметрыТекущегоКурса.Валюта = ПараметрыНовогоКурса.Валюта
		Или (ПараметрыТекущегоКурса.Курс = ПараметрыНовогоКурса.Курс 
			И ПараметрыТекущегоКурса.Кратность = ПараметрыНовогоКурса.Кратность) Тогда
		
		Возврат Сумма;
	КонецЕсли;
	
	Если ПараметрыТекущегоКурса.Курс = 0
		Или ПараметрыТекущегоКурса.Кратность = 0
		Или ПараметрыНовогоКурса.Курс = 0
		Или ПараметрыНовогоКурса.Кратность = 0 Тогда
		
		Возврат 0;
	КонецЕсли;
	
	Возврат Окр((Сумма * ПараметрыТекущегоКурса.Курс * ПараметрыНовогоКурса.Кратность) 
		/ (ПараметрыНовогоКурса.Курс * ПараметрыТекущегоКурса.Кратность), 2);
КонецФункции

#Область УстаревшиеПроцедурыИФункции

// Устарела. Следует использовать функцию ПересчитатьПоКурсу.
//
// Пересчитывает сумму из валюты ВалютаНач по курсу ПоКурсуНач 
// в валюту ВалютаКон по курсу ПоКурсуКон.
//
// Параметры:
//   Сумма          - Число - Сумма, которую следует пересчитать.
//   ВалютаНач      - СправочникСсылка.Валюты - Валюта, из которой надо пересчитать.
//   ВалютаКон      - СправочникСсылка.Валюты - Валюта, в  которую надо пересчитать.
//   ПоКурсуНач     - Число - Курс, из которого надо пересчитать.
//   ПоКурсуКон     - Число - Курс, в  который  надо пересчитать.
//   ПоКратностьНач - Число - Кратность, из которой надо пересчитать (по умолчанию = 1).
//   ПоКратностьКон - Число - Кратность, в  которую надо пересчитать (по умолчанию = 1).
//
// Возвращаемое значение: 
//   Число - Сумма, пересчитанная в другую валюту.
//
Функция ПересчитатьИзВалютыВВалюту(Сумма, ВалютаНач, ВалютаКон, ПоКурсуНач, ПоКурсуКон, 
	ПоКратностьНач = 1, ПоКратностьКон = 1) Экспорт
	
	Возврат ПересчитатьПоКурсу(
		Сумма, 
		Новый Структура("Валюта, Курс, Кратность", ВалютаНач, ПоКурсуНач, ПоКратностьНач),
		Новый Структура("Валюта, Курс, Кратность", ВалютаКон, ПоКурсуКон, ПоКратностьКон));
	
КонецФункции

#КонецОбласти

#КонецОбласти
