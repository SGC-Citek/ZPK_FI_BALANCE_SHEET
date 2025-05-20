@AbapCatalog.sqlViewName: 'ZSQLPSRTRLBALITM' 
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Trial Balance Item'
define view zi_finstmnt_trialbalitem
  with parameters
    P_FromPostingDate  : zde_fis_budat_from,
    P_ToPostingDate    : zde_fis_budat_to,
    P_FromFiscalPeriod : zde_fis_period_from,
    P_ToFiscalPeriod   : zde_fis_period_to
  as select from zi_finstmnt_trialballineitem2
                 ( P_FromPostingDate: $parameters.P_FromPostingDate,   P_ToPostingDate: $parameters.P_ToPostingDate,
                   P_FromFiscalPeriod: $parameters.P_FromFiscalPeriod, P_ToFiscalPeriod : $parameters.P_ToFiscalPeriod )

{
  key  Ledger,
  key  CompanyCode,
  key  FiscalYear,
  key  SourceLedger,
  key  AccountingDocument,
  key  LedgerGLLineItem,

       AccountingDocumentItem,
       FiscalPeriod,
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
       ReconciliationAccountType,
       Supplier,
       Customer,
       FinancialAccountType,
       SpecialGLCode,
       AccountingDocumentType,
       PostingKey,
       AccountingDocumentCategory,
       AccountingDocCreatedByUser,
       DebitCreditCode,
       CashJournalItemType,
       ItemType,
       TaxCode,

       //CE2308 expose JrnlEntryItemMigrationSource
       //Requirement from MX
       JrnlEntryItemMigrationSource,

       //CE2402 GR Requirement
       FiscalYearVariant,
       ReferenceDocument,

       //CE2402 expose  'OffsettingAccount' and 'OffsettingAccountType'
       //Requirement from BG
       OffsettingAccount,
       OffsettingAccountType,

       ////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Company Code Currency part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       CompanyCodeCurrency,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       CarryFwdBalAmtInCCCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalAmtInCCCrcy as zde_glo_dr_cfwd_bal_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_glo_dr_cfwd_bal_hsl )
             end as DebitCarryFwdBalAmtInCCCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalAmtInCCCrcy as zde_glo_cr_cfwd_bal_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_glo_cr_cfwd_bal_hsl )
             end as CreditCarryFwdBalAmtInCCCrcy,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       PrevPeriodYTDAmtInCCCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPeriodYTDAmtInCCCrcy as zde_glo_dr_ytd_bal_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_glo_dr_ytd_bal_hsl  )
             end as DebitPrevPeriodYTDAmtInCCCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPeriodYTDAmtInCCCrcy as zde_glo_cr_ytd_bal_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_glo_cr_ytd_bal_hsl )
             end as CreditPrevPeriodYTDAmtInCCCrcy,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       StartingBalanceAmtInCoCodeCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StartingBalanceAmtInCoCodeCrcy as zde_glo_dr_strt_bal_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_glo_dr_strt_bal_hsl )
             end as DebitStartingBalAmtInCCCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StartingBalanceAmtInCoCodeCrcy as zde_glo_cr_strt_bal_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_glo_cr_strt_bal_hsl )
             end as CreditStartingBalAmtInCCCrcy,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       AmountInCompanyCodeCurrency,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInCompanyCodeCurrency as zde_fis_dr_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_dr_hsl )
             end as DebitAmountInCoCodeCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInCompanyCodeCurrency as zde_fis_cr_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_cr_hsl )
             end as CreditAmountInCoCodeCrcy,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       EndingBalanceAmtInCoCodeCrcy,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalanceAmtInCoCodeCrcy as zde_glo_dr_end_bal_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_glo_dr_end_bal_hsl )
             end as DebitEndingBalAmtInCCCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalanceAmtInCoCodeCrcy as zde_fis_hsl )//glo_cr_end_bal_hsl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_hsl )
             end as CreditEndingBalAmtInCCCrcy,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       YTDAmtInLoclCrcy,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YTDAmtInLoclCrcy as zde_fis_hsl )//glo_dr_cytd_bal_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_hsl )
             end as YTDDebitAmtInCoCodeCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YTDAmtInLoclCrcy as zde_fis_hsl )//glo_cr_cytd_bal_hsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_hsl )
             end as YTDCrdtAmtInCoCodeCrcy,


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Transaction Currency part
       //////////////////////////////////////////////////////////////////////////////////////////////////////////////

       @Semantics.currencyCode:true
       TransactionCurrency,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       CarryFwdBalanceAmtInTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalanceAmtInTransCrcy as zde_fis_hsl )//glo_dr_cfwd_bal_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_wsl )
             end as DebitCarryFwdBalAmtInTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalanceAmtInTransCrcy as zde_fis_hsl )//glo_cr_cfwd_bal_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_wsl )
             end as CrdtCarryFwdBalAmtInTransCrcy,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       PrevPerdYTDAmountInTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPerdYTDAmountInTransCrcy as zde_fis_hsl )//glo_dr_ytd_bal_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_wsl  )
             end as DebitPrevPerdYTDAmtInTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPerdYTDAmountInTransCrcy as zde_fis_hsl )//glo_cr_ytd_bal_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_wsl )
             end as CrdtPrevPerdYTDAmtInTransCrcy,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       StartingBalanceAmtInTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StartingBalanceAmtInTransCrcy as zde_fis_hsl )//glo_dr_strt_bal_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_wsl )
             end as DebitStartingBalAmtInTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StartingBalanceAmtInTransCrcy as zde_fis_hsl )//glo_cr_strt_bal_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_wsl )
             end as CrdtStartingBalAmtInTransCrcy,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       AmountInTransactionCurrency,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInTransactionCurrency as zde_fis_hsl )//fis_dr_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_wsl )
             end as DebitAmountInTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInTransactionCurrency as zde_fis_hsl )//fis_cr_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_wsl )
             end as CreditAmountInTransCrcy,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       EndingBalanceAmtInTransCrcy,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalanceAmtInTransCrcy as zde_fis_hsl )//glo_dr_end_bal_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_wsl )
             end as DebitEndingBalAmtInTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalanceAmtInTransCrcy as zde_fis_hsl )//glo_cr_end_bal_wsl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_wsl )
             end as CreditEndingBalAmtInTransCrcy,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       YrToDteAmtInTransacCrcy,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YrToDteAmtInTransacCrcy as zde_fis_hsl )//glo_dr_cytd_bal_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_wsl )
             end as YTDDebitAmtInTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YrToDteAmtInTransacCrcy as zde_fis_hsl )//glo_cr_cytd_bal_wsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_wsl )
             end as YTDCrdtAmtInTransCrcy,


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Balance Transaction Currency part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

       @Semantics.currencyCode:true
       BalanceTransactionCurrency,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       CarryFwdBalAmtInBalTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalAmtInBalTransCrcy as zde_fis_hsl )//glo_dr_cfwd_bal_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_tsl )
             end as DebitCarryFwdBalAmtInBlTCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalAmtInBalTransCrcy as zde_fis_hsl )//glo_cr_cfwd_bal_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_tsl )
             end as CrdtCarryFwdBalAmtInBlTCrcy,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       PrevPeriodYTDAmtInBalTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPeriodYTDAmtInBalTransCrcy as zde_fis_hsl )//glo_dr_ytd_bal_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_tsl  )
             end as DebitPrevPerdYTDAmtInBlTCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPeriodYTDAmtInBalTransCrcy as zde_fis_hsl )//glo_cr_ytd_bal_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_tsl )
             end as CrdtPrevPerdYTDAmtInBlTCrcy,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       StartingBalAmtInBalTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StartingBalAmtInBalTransCrcy as zde_fis_hsl )//glo_dr_strt_bal_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_tsl )
             end as DebitStrtgBalAmtInBalTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StartingBalAmtInBalTransCrcy as zde_fis_hsl )//glo_cr_strt_bal_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_tsl )
             end as CrdtStrtgBalAmtInBalTransCrcy,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       AmountInBalanceTransacCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInBalanceTransacCrcy as zde_fis_hsl )//fis_dr_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_tsl )
             end as DebitAmountInBalanceTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInBalanceTransacCrcy as zde_fis_hsl )//fis_cr_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_tsl )
             end as CreditAmountInBalanceTransCrcy,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       EndingBalanceAmtInBalTransCrcy,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalanceAmtInBalTransCrcy as zde_fis_hsl )//glo_dr_end_bal_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_tsl )
             end as DebitEndgBalAmtInBalTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalanceAmtInBalTransCrcy as zde_fis_hsl )//glo_cr_end_bal_tsl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_tsl )
             end as CreditEndgBalAmtInBalTransCrcy,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       YearToDateAmountInBalTransCrcy,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YearToDateAmountInBalTransCrcy as zde_fis_hsl )//glo_dr_cytd_bal_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_tsl )
             end as DebitYTDAmountInBalTransCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YearToDateAmountInBalTransCrcy as zde_fis_hsl )//glo_cr_cytd_bal_tsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_tsl )
             end as CreditYTDAmountInBalTransCrcy,


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Global Currency part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       GlobalCurrency,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       CarryFwdBalanceAmtInGlobalCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalanceAmtInGlobalCrcy as zde_fis_hsl )//glo_dr_cfwd_bal_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_ksl )
             end as DebitCarryFwdBalAmtInGlobCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalanceAmtInGlobalCrcy as zde_fis_hsl )//glo_cr_cfwd_bal_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_ksl )
             end as CrdtCarryFwdBalAmtInGlobalCrcy,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       PrevPerdYTDAmountInGlobalCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPerdYTDAmountInGlobalCrcy as zde_fis_hsl )//glo_dr_ytd_bal_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_ksl  )
             end as DebitPrevPerdYTDAmtInGlobCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPerdYTDAmountInGlobalCrcy as zde_fis_hsl )//glo_cr_ytd_bal_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_ksl )
             end as CreditPrevPerdYTDAmtInGlobCrcy,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       StartingBalanceAmtInGlobalCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'S' 
           then
             cast( StartingBalanceAmtInGlobalCrcy as zde_fis_hsl )//glo_dr_strt_bal_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_ksl )
             end as DebitStartingBalAmtInGlobCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
        
         when 'H'
           then
              cast( 0 - StartingBalanceAmtInGlobalCrcy as zde_fis_hsl )//glo_cr_strt_bal_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_ksl )
             end as CreditStartingBalAmtInGlobCrcy,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       AmountInGlobalCurrency,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInGlobalCurrency as zde_fis_hsl )//fis_dr_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_ksl )
             end as DebitAmountInGlobalCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInGlobalCurrency as zde_fis_hsl )//fis_cr_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_ksl )
             end as CreditAmountInGlobalCrcy,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       EndingBalanceAmtInGlobalCrcy,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalanceAmtInGlobalCrcy as zde_fis_hsl )//glo_dr_end_bal_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_ksl )
             end as DebitEndingBalAmtInGlobalCrcy,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalanceAmtInGlobalCrcy as zde_fis_hsl )//glo_cr_end_bal_ksl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_ksl )
             end as CreditEndingBalAmtInGlobalCrcy,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       YearToDateAmountInGlobalCrcy,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YearToDateAmountInGlobalCrcy as zde_fis_hsl )//glo_dr_cytd_bal_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_ksl )
             end as DebitYTDAmountInGlobalCurrency,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YearToDateAmountInGlobalCrcy as zde_fis_hsl )//glo_cr_cytd_bal_ksl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_ksl )
             end as CreditYTDAmtInGlobalCurrency,


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 1 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency1,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       CarryFwdBalAmountInFDCrcy1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalAmountInFDCrcy1 as zde_fis_hsl )//glo_dr_cfwd_bal_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_osl )
             end as DebitCarryFwdBalAmtInFDCrcy1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalAmountInFDCrcy1 as zde_fis_hsl )//glo_cr_cfwd_bal_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_osl )
             end as CreditCarryFwdBalAmtInFDCrcy1,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       PrevPerdYTDAmountInFDCrcy1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPerdYTDAmountInFDCrcy1 as zde_fis_hsl )//glo_dr_ytd_bal_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_osl  )
             end as DebitPrevPerdYTDAmtInFDCrcy1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPerdYTDAmountInFDCrcy1 as zde_fis_hsl )//glo_cr_ytd_bal_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_osl )
             end as CreditPrevPerdYTDAmtInFDCrcy1,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       StrtgBalAmtInFreeDfndCrcy1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StrtgBalAmtInFreeDfndCrcy1 as zde_fis_hsl )//glo_dr_strt_bal_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_osl )
             end as DebitStartBalAmountInFDCrcy1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StrtgBalAmtInFreeDfndCrcy1 as zde_fis_hsl )//glo_cr_strt_bal_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_osl )
             end as CreditStartBalAmountInFDCrcy1,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       AmountInFreeDefinedCurrency1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInFreeDefinedCurrency1 as zde_fis_hsl )//fis_dr_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_osl )
             end as DebitAmountInFreeDfndCrcy1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInFreeDefinedCurrency1 as zde_fis_hsl )//fis_cr_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_osl )
             end as CreditAmountInFreeDfndCrcy1,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       EndingBalAmtInFreeDfndCrcy1,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalAmtInFreeDfndCrcy1 as zde_fis_hsl )//glo_dr_end_bal_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_osl )
             end as DebitEndingBalAmountInFDCrcy1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalAmtInFreeDfndCrcy1 as zde_fis_hsl )//glo_cr_end_bal_osl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_osl )
             end as CreditEndingBalAmountInFDCrcy1,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       YearToDateAmountInFDCrcy1,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YearToDateAmountInFDCrcy1 as zde_fis_hsl )//glo_dr_cytd_bal_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_osl )
             end as DebitYTDAmountInFDCrcy1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YearToDateAmountInFDCrcy1 as zde_fis_hsl )//glo_cr_cytd_bal_osl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_osl )
             end as CreditYTDAmountInFDCrcy1,


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 2 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency2,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       CarryFwdBalAmountInFDCrcy2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalAmountInFDCrcy2 as zde_fis_hsl )//glo_dr_cfwd_bal_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_vsl )
             end as DebitCarryFwdBalAmtInFDCrcy2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalAmountInFDCrcy2 as zde_fis_hsl )//glo_cr_cfwd_bal_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_vsl )
             end as CreditCarryFwdBalAmtInFDCrcy2,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       PrevPerdYTDAmountInFDCrcy2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPerdYTDAmountInFDCrcy2 as zde_fis_hsl )//glo_dr_ytd_bal_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_vsl  )
             end as DebitPrevPerdYTDAmtInFDCrcy2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPerdYTDAmountInFDCrcy2 as zde_fis_hsl )//glo_cr_ytd_bal_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_vsl )
             end as CreditPrevPerdYTDAmtInFDCrcy2,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       StrtgBalAmtInFreeDfndCrcy2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StrtgBalAmtInFreeDfndCrcy2 as zde_fis_hsl )//glo_dr_strt_bal_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_vsl )
             end as DebitStartBalAmountInFDCrcy2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StrtgBalAmtInFreeDfndCrcy2 as zde_fis_hsl )//glo_cr_strt_bal_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_vsl )
             end as CreditStartBalAmountInFDCrcy2,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       AmountInFreeDefinedCurrency2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInFreeDefinedCurrency2 as zde_fis_hsl )//fis_dr_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_vsl )
             end as DebitAmountInFreeDfndCrcy2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInFreeDefinedCurrency2 as zde_fis_hsl )//fis_cr_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_vsl )
             end as CreditAmountInFreeDfndCrcy2,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       EndingBalAmtInFreeDfndCrcy2,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalAmtInFreeDfndCrcy2 as zde_fis_hsl )//glo_dr_end_bal_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_vsl )
             end as DebitEndingBalAmountInFDCrcy2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalAmtInFreeDfndCrcy2 as zde_fis_hsl )//glo_cr_end_bal_vsl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_vsl )
             end as CreditEndingBalAmountInFDCrcy2,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       YearToDateAmountInFDCrcy2,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YearToDateAmountInFDCrcy2 as zde_fis_hsl )//glo_dr_cytd_bal_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_vsl )
             end as DebitYTDAmountInFDCrcy2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YearToDateAmountInFDCrcy2 as zde_fis_hsl )//glo_cr_cytd_bal_vsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_vsl )
             end as CreditYTDAmountInFDCrcy2,


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 3 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency3,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       CarryFwdBalAmountInFDCrcy3,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalAmountInFDCrcy3 as zde_fis_hsl )//glo_dr_cfwd_bal_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_bsl )
             end as DebitCarryFwdBalAmtInFDCrcy3,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalAmountInFDCrcy3 as zde_fis_hsl )//glo_cr_cfwd_bal_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_bsl )
             end as CreditCarryFwdBalAmtInFDCrcy3,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       PrevPerdYTDAmountInFDCrcy3,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPerdYTDAmountInFDCrcy3 as zde_fis_hsl )//glo_dr_ytd_bal_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_bsl  )
             end as DebitPrevPerdYTDAmtInFDCrcy3,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPerdYTDAmountInFDCrcy3 as zde_fis_hsl )//glo_cr_ytd_bal_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_bsl )
             end as CreditPrevPerdYTDAmtInFDCrcy3,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       StrtgBalAmtInFreeDfndCrcy3,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StrtgBalAmtInFreeDfndCrcy3 as zde_fis_hsl )//glo_dr_strt_bal_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_bsl )
             end as DebitStartBalAmountInFDCrcy3,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StrtgBalAmtInFreeDfndCrcy3 as zde_fis_hsl )//glo_cr_strt_bal_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_bsl )
             end as CreditStartBalAmountInFDCrcy3,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       AmountInFreeDefinedCurrency3,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInFreeDefinedCurrency3 as zde_fis_hsl )//fis_dr_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_bsl )
             end as DebitAmountInFreeDfndCrcy3,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInFreeDefinedCurrency3 as zde_fis_hsl )//fis_cr_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_bsl )
             end as CreditAmountInFreeDfndCrcy3,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       EndingBalAmtInFreeDfndCrcy3,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalAmtInFreeDfndCrcy3 as zde_fis_hsl )//glo_dr_end_bal_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_bsl )
             end as DebitEndingBalAmountInFDCrcy3,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalAmtInFreeDfndCrcy3 as zde_fis_hsl )//glo_cr_end_bal_bsl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_bsl )
             end as CreditEndingBalAmountInFDCrcy3,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       YearToDateAmountInFDCrcy3,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YearToDateAmountInFDCrcy3 as zde_fis_hsl )//glo_dr_cytd_bal_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_bsl )
             end as DebitYTDAmountInFDCrcy3,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YearToDateAmountInFDCrcy3 as zde_fis_hsl )//glo_cr_cytd_bal_bsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_bsl )
             end as CreditYTDAmountInFDCrcy3,


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 4 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency4,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       CarryFwdBalAmountInFDCrcy4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalAmountInFDCrcy4 as zde_fis_hsl )//glo_dr_cfwd_bal_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_csl )
             end as DebitCarryFwdBalAmtInFDCrcy4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalAmountInFDCrcy4 as zde_fis_hsl )//glo_cr_cfwd_bal_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_csl )
             end as CreditCarryFwdBalAmtInFDCrcy4,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       PrevPerdYTDAmountInFDCrcy4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPerdYTDAmountInFDCrcy4 as zde_fis_hsl )//glo_dr_ytd_bal_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_csl  )
             end as DebitPrevPerdYTDAmtInFDCrcy4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPerdYTDAmountInFDCrcy4 as zde_fis_hsl )//glo_cr_ytd_bal_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_csl )
             end as CreditPrevPerdYTDAmtInFDCrcy4,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       StrtgBalAmtInFreeDfndCrcy4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StrtgBalAmtInFreeDfndCrcy4 as zde_fis_hsl )//glo_dr_strt_bal_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_csl )
             end as DebitStartBalAmountInFDCrcy4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StrtgBalAmtInFreeDfndCrcy4 as zde_fis_hsl )//glo_cr_strt_bal_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_csl )
             end as CreditStartBalAmountInFDCrcy4,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       AmountInFreeDefinedCurrency4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInFreeDefinedCurrency4 as zde_fis_hsl )//fis_dr_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_csl )
             end as DebitAmountInFreeDfndCrcy4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInFreeDefinedCurrency4 as zde_fis_hsl )//fis_cr_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_csl )
             end as CreditAmountInFreeDfndCrcy4,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       EndingBalAmtInFreeDfndCrcy4,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalAmtInFreeDfndCrcy4 as zde_fis_hsl )//glo_dr_end_bal_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_csl )
             end as DebitEndingBalAmountInFDCrcy4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalAmtInFreeDfndCrcy4 as zde_fis_hsl )//glo_cr_end_bal_csl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_csl )
             end as CreditEndingBalAmountInFDCrcy4,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       YearToDateAmountInFDCrcy4,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YearToDateAmountInFDCrcy4 as zde_fis_hsl )//glo_dr_cytd_bal_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_csl )
             end as DebitYTDAmountInFDCrcy4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YearToDateAmountInFDCrcy4 as zde_fis_hsl )//glo_cr_cytd_bal_csl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_csl )
             end as CreditYTDAmountInFDCrcy4,


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 5 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency5,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       CarryFwdBalAmountInFDCrcy5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalAmountInFDCrcy5 as zde_fis_hsl )//glo_dr_cfwd_bal_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_dsl )
             end as DebitCarryFwdBalAmtInFDCrcy5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalAmountInFDCrcy5 as zde_fis_hsl )//glo_cr_cfwd_bal_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_dsl )
             end as CreditCarryFwdBalAmtInFDCrcy5,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       PrevPerdYTDAmountInFDCrcy5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPerdYTDAmountInFDCrcy5 as zde_fis_hsl )//glo_dr_ytd_bal_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_dsl  )
             end as DebitPrevPerdYTDAmtInFDCrcy5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPerdYTDAmountInFDCrcy5 as zde_fis_hsl )//glo_cr_ytd_bal_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_dsl )
             end as CreditPrevPerdYTDAmtInFDCrcy5,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       StrtgBalAmtInFreeDfndCrcy5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StrtgBalAmtInFreeDfndCrcy5 as zde_fis_hsl )//glo_dr_strt_bal_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_dsl )
             end as DebitStartBalAmountInFDCrcy5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StrtgBalAmtInFreeDfndCrcy5 as zde_fis_hsl )//glo_cr_strt_bal_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_dsl )
             end as CreditStartBalAmountInFDCrcy5,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       AmountInFreeDefinedCurrency5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInFreeDefinedCurrency5 as zde_fis_hsl )//fis_dr_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_dsl )
             end as DebitAmountInFreeDfndCrcy5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInFreeDefinedCurrency5 as zde_fis_hsl )//fis_cr_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_dsl )
             end as CreditAmountInFreeDfndCrcy5,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       EndingBalAmtInFreeDfndCrcy5,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalAmtInFreeDfndCrcy5 as zde_fis_hsl )//glo_dr_end_bal_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_dsl )
             end as DebitEndingBalAmountInFDCrcy5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalAmtInFreeDfndCrcy5 as zde_fis_hsl )//glo_cr_end_bal_dsl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_dsl )
             end as CreditEndingBalAmountInFDCrcy5,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       YearToDateAmountInFDCrcy5,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YearToDateAmountInFDCrcy5 as zde_fis_hsl )//glo_dr_cytd_bal_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_dsl )
             end as DebitYTDAmountInFDCrcy5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YearToDateAmountInFDCrcy5 as zde_fis_hsl )//glo_cr_cytd_bal_dsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_dsl )
             end as CreditYTDAmountInFDCrcy5,

       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 6 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency6,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       CarryFwdBalAmountInFDCrcy6,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalAmountInFDCrcy6 as zde_fis_hsl )//glo_dr_cfwd_bal_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_esl )
             end as DebitCarryFwdBalAmtInFDCrcy6,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalAmountInFDCrcy6 as zde_fis_hsl )//glo_cr_cfwd_bal_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_esl )
             end as CreditCarryFwdBalAmtInFDCrcy6,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       PrevPerdYTDAmountInFDCrcy6,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPerdYTDAmountInFDCrcy6 as zde_fis_hsl )//glo_dr_ytd_bal_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_esl  )
             end as DebitPrevPerdYTDAmtInFDCrcy6,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPerdYTDAmountInFDCrcy6 as zde_fis_hsl )//glo_cr_ytd_bal_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_esl )
             end as CreditPrevPerdYTDAmtInFDCrcy6,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       StrtgBalAmtInFreeDfndCrcy6,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StrtgBalAmtInFreeDfndCrcy6 as zde_fis_hsl )//glo_dr_strt_bal_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_esl )
             end as DebitStartBalAmountInFDCrcy6,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StrtgBalAmtInFreeDfndCrcy6 as zde_fis_hsl )//glo_cr_strt_bal_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_esl )
             end as CreditStartBalAmountInFDCrcy6,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       AmountInFreeDefinedCurrency6,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInFreeDefinedCurrency6 as zde_fis_hsl )//fis_dr_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_esl )
             end as DebitAmountInFreeDfndCrcy6,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInFreeDefinedCurrency6 as zde_fis_hsl )//fis_cr_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_esl )
             end as CreditAmountInFreeDfndCrcy6,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       EndingBalAmtInFreeDfndCrcy6,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalAmtInFreeDfndCrcy6 as zde_fis_hsl )//glo_dr_end_bal_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_esl )
             end as DebitEndingBalAmountInFDCrcy6,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalAmtInFreeDfndCrcy6 as zde_fis_hsl )//glo_cr_end_bal_esl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_esl )
             end as CreditEndingBalAmountInFDCrcy6,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       YearToDateAmountInFDCrcy6,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YearToDateAmountInFDCrcy6 as zde_fis_hsl )//glo_dr_cytd_bal_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_esl )
             end as DebitYTDAmountInFDCrcy6,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YearToDateAmountInFDCrcy6 as zde_fis_hsl )//glo_cr_cytd_bal_esl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_esl )
             end as CreditYTDAmountInFDCrcy6,


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 7 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency7,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       CarryFwdBalAmountInFDCrcy7,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalAmountInFDCrcy7 as zde_fis_hsl )//glo_dr_cfwd_bal_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_fsl )
             end as DebitCarryFwdBalAmtInFDCrcy7,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalAmountInFDCrcy7 as zde_fis_hsl )//glo_cr_cfwd_bal_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_fsl )
             end as CreditCarryFwdBalAmtInFDCrcy7,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       PrevPerdYTDAmountInFDCrcy7,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPerdYTDAmountInFDCrcy7 as zde_fis_hsl )//glo_dr_ytd_bal_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_fsl  )
             end as DebitPrevPerdYTDAmtInFDCrcy7,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPerdYTDAmountInFDCrcy7 as zde_fis_hsl )//glo_cr_ytd_bal_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_fsl )
             end as CreditPrevPerdYTDAmtInFDCrcy7,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       StrtgBalAmtInFreeDfndCrcy7,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StrtgBalAmtInFreeDfndCrcy7 as zde_fis_hsl )//glo_dr_strt_bal_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_fsl )
             end as DebitStartBalAmountInFDCrcy7,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StrtgBalAmtInFreeDfndCrcy7 as zde_fis_hsl )//glo_cr_strt_bal_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_fsl )
             end as CreditStartBalAmountInFDCrcy7,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       AmountInFreeDefinedCurrency7,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInFreeDefinedCurrency7 as zde_fis_hsl )//fis_dr_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_fsl )
             end as DebitAmountInFreeDfndCrcy7,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInFreeDefinedCurrency7 as zde_fis_hsl )//fis_cr_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_fsl )
             end as CreditAmountInFreeDfndCrcy7,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       EndingBalAmtInFreeDfndCrcy7,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalAmtInFreeDfndCrcy7 as zde_fis_hsl )//glo_dr_end_bal_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_fsl )
             end as DebitEndingBalAmountInFDCrcy7,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalAmtInFreeDfndCrcy7 as zde_fis_hsl )//glo_cr_end_bal_fsl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_fsl )
             end as CreditEndingBalAmountInFDCrcy7,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       YearToDateAmountInFDCrcy7,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YearToDateAmountInFDCrcy7 as zde_fis_hsl )//glo_dr_cytd_bal_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_fsl )
             end as DebitYTDAmountInFDCrcy7,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YearToDateAmountInFDCrcy7 as zde_fis_hsl )//glo_cr_cytd_bal_fsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_fsl )
             end as CreditYTDAmountInFDCrcy7,

       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 8 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency8,

       //Balance carry forward
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       CarryFwdBalAmountInFDCrcy8,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'S'
           then
              cast( CarryFwdBalAmountInFDCrcy8 as zde_fis_hsl )//glo_dr_cfwd_bal_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cfwd_bal_gsl )
             end as DebitCarryFwdBalAmtInFDCrcy8,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - CarryFwdBalAmountInFDCrcy8 as zde_fis_hsl )//glo_cr_cfwd_bal_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cfwd_bal_gsl )
             end as CreditCarryFwdBalAmtInFDCrcy8,

       ////Previous period year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       PrevPerdYTDAmountInFDCrcy8,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'S'
           then
             cast( PrevPerdYTDAmountInFDCrcy8 as zde_fis_hsl )//glo_dr_ytd_bal_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_ytd_bal_gsl  )
             end as DebitPrevPerdYTDAmtInFDCrcy8,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - PrevPerdYTDAmountInFDCrcy8 as zde_fis_hsl )//glo_cr_ytd_bal_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_ytd_bal_gsl )
             end as CreditPrevPerdYTDAmtInFDCrcy8,

       ////Starting Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       StrtgBalAmtInFreeDfndCrcy8,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'S'
           then
             cast( StrtgBalAmtInFreeDfndCrcy8 as zde_fis_hsl )//glo_dr_strt_bal_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_strt_bal_gsl )
             end as DebitStartBalAmountInFDCrcy8,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'H'
           then
              cast( 0 - StrtgBalAmtInFreeDfndCrcy8 as zde_fis_hsl )//glo_cr_strt_bal_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_strt_bal_gsl )
             end as CreditStartBalAmountInFDCrcy8,

       ////current balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       AmountInFreeDefinedCurrency8,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'S'
           then
             cast( AmountInFreeDefinedCurrency8 as zde_fis_hsl )//fis_dr_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_dr_gsl )
             end as DebitAmountInFreeDfndCrcy8,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - AmountInFreeDefinedCurrency8 as zde_fis_hsl )//fis_cr_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//fis_cr_gsl )
             end as CreditAmountInFreeDfndCrcy8,


       //Ending Balance
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       EndingBalAmtInFreeDfndCrcy8,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'S'
           then
             cast( EndingBalAmtInFreeDfndCrcy8 as zde_fis_hsl )//glo_dr_end_bal_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_end_bal_gsl )
             end as DebitEndingBalAmountInFDCrcy8,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - EndingBalAmtInFreeDfndCrcy8 as zde_fis_hsl )//glo_cr_end_bal_gsl)
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_end_bal_gsl )
             end as CreditEndingBalAmountInFDCrcy8,

       //Year to date amount
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       YearToDateAmountInFDCrcy8,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'S'
           then
             cast( YearToDateAmountInFDCrcy8 as zde_fis_hsl )//glo_dr_cytd_bal_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_dr_cytd_bal_gsl )
             end as DebitYTDAmountInFDCrcy8,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case DebitCreditCode
         when 'H'
           then
             cast( 0 - YearToDateAmountInFDCrcy8 as zde_fis_hsl )//glo_cr_cytd_bal_gsl )
           else
             cast( cast( 0 as abap.dec(23,2) ) as zde_fis_hsl )//glo_cr_cytd_bal_gsl )
             end as CreditYTDAmountInFDCrcy8,


       AssignmentReference,
       DocumentItemText,

       _Supplier,
       _Customer,
       _CompanyCode,
       _GLAccountText,
       _GLAccountInChartOfAccounts,
       _GLAccountInCompanyCode,
       _ProfitCenter,
       _FunctionalArea,
       _BusinessArea,
       _Segment,
       _AlternativeGLAccount,
       _ControllingArea,
       _CountryChartOfAccounts,
       _ChartOfAccounts,
       _TaxCode,
       //CE2402 GR Requirement
       _AccountingDocumentType,
       _PostingKey,
       _JournalEntry

}
where
  IsSelected = 'X'
