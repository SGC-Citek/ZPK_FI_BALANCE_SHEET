@AbapCatalog.sqlViewName: 'ZSQL_TRLBALITM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Trial Balance Line Item'
define view zi_finstmnt_trialballineitem
  with parameters
    P_FromPostingDate : zde_fis_budat_from,
    P_ToPostingDate   : zde_fis_budat_to
  as select from    I_GLAccountLineItem
    left outer join I_FiscalCalendarDate on  I_FiscalCalendarDate.FiscalYearVariant = I_GLAccountLineItem.FiscalYearVariant
                                         and I_FiscalCalendarDate.CalendarDate      = $parameters.P_FromPostingDate
{
  key Ledger,
  key CompanyCode,
  key I_GLAccountLineItem.FiscalYear,
  key SourceLedger,
  key AccountingDocument,
  key LedgerGLLineItem,

      AccountingDocumentItem,
      @ObjectModel.foreignKey.association: '_FiscalPeriodForVariant'
      @Semantics.fiscal.period: true
      I_GLAccountLineItem.FiscalPeriod,
      I_GLAccountLineItem.FiscalYearVariant,
      LedgerFiscalYear,
      PostingDate,
      DocumentDate,
      IsReversal,
      IsReversed,
      ProfitCenter,
      FunctionalArea,
      BusinessArea,
      ControllingArea,
      Segment,
      ChartOfAccounts,
      AlternativeGLAccount,
      CountryChartOfAccounts,
      GLAccount,
      _GLAccountInCompanyCode.ReconciliationAccountType,
      Supplier,
      Customer,
      FinancialAccountType,
      SpecialGLCode,
      AccountingDocumentType,
      PostingKey,
      AccountingDocumentCategory,
      AccountingDocCreatedByUser,
      DebitCreditCode,
      TaxCode,

      case FinancialAccountType
         when 'K'
         then FinancialAccountType  //Supplier
         when 'D'
         then FinancialAccountType  //Customer
         when ' '
         then
           case _GLAccountInCompanyCode.ReconciliationAccountType
             when 'K'
             then _GLAccountInCompanyCode.ReconciliationAccountType  //Supplier
             when 'D'
             then _GLAccountInCompanyCode.ReconciliationAccountType  //Customer
             else cast( ' ' as abap.char(1))
           end
         else cast( ' ' as abap.char(1))
      end                         as CashJournalItemType,

      //ItemType
      // 1 - item relevant for both OperationalBalance and JournalItemBalance
      // 2 - item relevant for both JournalItemBalance only
      cast ( case AccountingDocumentItem //BSEG-BUZEI
        when '000' then
           case AccountingDocumentCategory //BSEG-BSTAT
             when 'C' then cast( '3' as abap.char(1))   // carry forward
             else cast( '2' as abap.char(1))
           end
        else cast( '1' as abap.char(1))
      end  as zde_glo_item_type ) as ItemType,


      //CE2308 expose JrnlEntryItemMigrationSource
      //Requirement from MX
      JrnlEntryItemMigrationSource,

      //CE2402 expose  'OffsettingAccount' and 'OffsettingAccountType'
      //Requirement from BG
      OffsettingAccount,
      OffsettingAccountType,

      @Semantics.currencyCode:true
      CompanyCodeCurrency,
      @DefaultAggregation: #SUM
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      AmountInCompanyCodeCurrency,

      @Semantics.currencyCode:true
      TransactionCurrency,
      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
      AmountInTransactionCurrency,

      @Semantics.currencyCode:true
      BalanceTransactionCurrency,
      @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      AmountInBalanceTransacCrcy,

      @Semantics.currencyCode:true
      GlobalCurrency,
      @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
      AmountInGlobalCurrency,

      @Semantics.currencyCode:true
      FreeDefinedCurrency1,
      @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
      AmountInFreeDefinedCurrency1,

      @Semantics.currencyCode:true
      FreeDefinedCurrency2,
      @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
      AmountInFreeDefinedCurrency2,

      @Semantics.currencyCode:true
      FreeDefinedCurrency3,
      @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
      AmountInFreeDefinedCurrency3,

      @Semantics.currencyCode:true
      FreeDefinedCurrency4,
      @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
      AmountInFreeDefinedCurrency4,

      @Semantics.currencyCode:true
      FreeDefinedCurrency5,
      @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
      AmountInFreeDefinedCurrency5,

      @Semantics.currencyCode:true
      FreeDefinedCurrency6,
      @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
      AmountInFreeDefinedCurrency6,

      @Semantics.currencyCode:true
      FreeDefinedCurrency7,
      @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
      AmountInFreeDefinedCurrency7,

      @Semantics.currencyCode:true
      FreeDefinedCurrency8,
      @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
      AmountInFreeDefinedCurrency8,

      AssignmentReference,
      DocumentItemText,

      //CE2402 GR Requirement
      ReferenceDocument,

      _Supplier,
      _Customer,
      _GLAccountText,
      _GLAccountInChartOfAccounts,
      _ProfitCenter,
      _FunctionalArea,
      _BusinessArea,
      _Segment,
      _AlternativeGLAccount,
      _ControllingArea,
      _CountryChartOfAccounts,
      _ChartOfAccounts,
      _GLAccountInCompanyCode,
      _Ledger,
      _CompanyCode,
      _AccountingDocumentType,
      _FiscalYear,
      _SourceLedger,
      //_JournalEntry,
      _FiscalPeriodForVariant,
      _FiscalYearVariant,
      _LedgerFiscalYearForVariant,
      _FinancialAccountType,
      _PostingKey,
      _SpecialGLCode,
      _AccountingDocumentCategory,
      _DebitCreditCode,
      _TaxCode,
      _CompanyCodeCurrency,
      _TransactionCurrency,
      _BalanceTransactionCurrency,
      _GlobalCurrency,
      _FreeDefinedCurrency1,
      _FreeDefinedCurrency2,
      _FreeDefinedCurrency3,
      _FreeDefinedCurrency4,
      _FreeDefinedCurrency5,
      _FreeDefinedCurrency6,
      _FreeDefinedCurrency7,
      _FreeDefinedCurrency8,
      //CE2402 GR Requirement
      _JournalEntry
}
where
          I_GLAccountLineItem.LedgerFiscalYear >= I_FiscalCalendarDate.FiscalYear
  and     PostingDate                          <= $parameters.P_ToPostingDate
  and(
    (
          I_GLAccountLineItem.FiscalPeriod     =  '000'
      and I_GLAccountLineItem.LedgerFiscalYear =  I_FiscalCalendarDate.FiscalYear
    )
    or(
          I_GLAccountLineItem.FiscalPeriod     != '000'
    )
  )
