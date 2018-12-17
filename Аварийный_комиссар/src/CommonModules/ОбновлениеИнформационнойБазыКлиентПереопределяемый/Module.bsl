///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Вызывается при нажатии на гиперссылку или двойном щелчке на ячейке 
// табличного документа с описанием изменений системы (общий макет ОписаниеИзмененийСистемы).
//
// Параметры:
//   Область - ОбластьЯчеекТабличногоДокумента - область документа, на 
//             которой произошло нажатие.
//
Процедура ПриНажатииНаГиперссылкуВДокументеОписанияОбновлений(Знач Область) Экспорт
	
	

КонецПроцедуры

// Вызывается в обработчике ПередНачаломРаботыСистемы, проверяет возможность
// обновления на текущую версию программы.
//
// Параметры:
//  ВерсияДанных - Строка - версия данных основной конфигурации, с которой выполняется обновление
//                          (из регистра сведений ВерсииПодсистем).
//
Процедура ПриОпределенииВозможностиОбновления(Знач ВерсияДанных) Экспорт
	
	
	
КонецПроцедуры

#КонецОбласти
