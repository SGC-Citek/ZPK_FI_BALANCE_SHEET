@AbapCatalog.sqlViewName: 'ZSQL_TRLBALITM2'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Trial Balance Line Item 2'
define view zi_finstmnt_trialballineitem2
  with parameters
    P_FromPostingDate  : zde_fis_budat_from,
    P_ToPostingDate    : zde_fis_budat_to,
    P_FromFiscalPeriod : zde_fis_period_from,
    P_ToFiscalPeriod   : zde_fis_period_to
  as select from zi_finstmnt_trialballineitem
                 ( P_FromPostingDate: $parameters.P_FromPostingDate, P_ToPostingDate: $parameters.P_ToPostingDate )
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
       FiscalYearVariant,
       LedgerFiscalYear,
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
       AssignmentReference,
       DocumentItemText,
       TaxCode,

       //CE2308 expose JrnlEntryItemMigrationSource
       //Requirement from MX
       JrnlEntryItemMigrationSource,

       //CE2402 GR Requirement
       ReferenceDocument,

       //CE2402 expose  'OffsettingAccount' and 'OffsettingAccountType'
       //Requirement from BG
       OffsettingAccount,
       OffsettingAccountType,


       case $parameters.P_FromFiscalPeriod
         when '000'
           then
             'X'
         else
           case
             when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
               then 'X'
             else cast( ' ' as abap.char(1))
             end
          end                               as IsSelected, //Item is really selected for caculation


       ////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Company Code Currency part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       CompanyCodeCurrency,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInCompanyCodeCurrency
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_hsl ) as CarryFwdBalAmtInCCCrcy, //Year Beginning Carry Forward Balance in Company Code Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       cast(
         case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInCompanyCodeCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInCompanyCodeCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
         end as  zde_glo_ytd_bal_hsl )      as PrevPeriodYTDAmtInCCCrcy,       //Previous Period Year to Date Amount in Company Code Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInCompanyCodeCurrency
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInCompanyCodeCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInCompanyCodeCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StartingBalanceAmtInCoCodeCrcy, //Starting Balance in Company Code Currency



       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInCompanyCodeCurrency
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
                AmountInCompanyCodeCurrency
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInCompanyCodeCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalanceAmtInCoCodeCrcy, //Ending Balance in Company Code Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInCompanyCodeCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInCompanyCodeCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_hsl )                 as AmountInCompanyCodeCurrency, //Current Period Balance in Company Code Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInCompanyCodeCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInCompanyCodeCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YTDAmtInLoclCrcy, //Year to Date Amount in Company Code Currency




       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Transaction Currency part
       //////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       TransactionCurrency,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInTransactionCurrency
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_wsl ) as CarryFwdBalanceAmtInTransCrcy, //Carry Forward Amount in Transation Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
             when PostingDate < $parameters.P_FromPostingDate
             then AmountInTransactionCurrency
             else cast( '0' as abap.curr( 23,2))
           end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInTransactionCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_wsl )        as PrevPerdYTDAmountInTransCrcy,  //Previous Period Year to Date Amount in Transaction Currency



       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInTransactionCurrency
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
             when PostingDate < $parameters.P_FromPostingDate
             then AmountInTransactionCurrency
             else cast( '0' as abap.curr( 23,2))
           end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInTransactionCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_wsl_ui )        as StartingBalanceAmtInTransCrcy, //Period Starting Balance in Transaction Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
             when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
             then AmountInTransactionCurrency
             else cast( '0' as abap.curr( 23,2))
           end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInTransactionCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_wsl )                     as AmountInTransactionCurrency, //Current Period Balance in Transaction Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       cast( case FiscalPeriod
       when '000'
       then AmountInCompanyCodeCurrency
       else
       case $parameters.P_FromFiscalPeriod
       when '000'
       then
         AmountInTransactionCurrency
       else
        case
          when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
            then AmountInTransactionCurrency
          else cast( '0' as abap.curr( 23,2))
        end
       end
       end as   zde_fis_end_bal_hsl )       as EndingBalanceAmtInTransCrcy, //Ending Balance in Transaction Currency



       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInTransactionCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInTransactionCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YrToDteAmtInTransacCrcy, //Year to data amount in Transaction currency

       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Balance Transaction Currency part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       BalanceTransactionCurrency,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInBalanceTransacCrcy
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_tsl )     as CarryFwdBalAmtInBalTransCrcy, //Carry Forward Balance in Balance Transaction Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInBalanceTransacCrcy
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInBalanceTransacCrcy
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_hsl )        as PrevPeriodYTDAmtInBalTransCrcy, //Previous period Year to Date Amount in Balance Transaction Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInBalanceTransacCrcy
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInBalanceTransacCrcy
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInBalanceTransacCrcy
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StartingBalAmtInBalTransCrcy, //Starting Balance in Balance Transaction Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInBalanceTransacCrcy
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInBalanceTransacCrcy
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end                                  as AmountInBalanceTransacCrcy, //Current Period Balance in Balance Transaction Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInBalanceTransacCrcy
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
       //AmountInCompanyCodeCurrency     "CE2308
                AmountInBalanceTransacCrcy        //CE2308
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInBalanceTransacCrcy
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalanceAmtInBalTransCrcy, //Ending Balance in Balance Transaction Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInBalanceTransacCrcy
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInBalanceTransacCrcy
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YearToDateAmountInBalTransCrcy, //Year to Date Amount in Balance Transaction currency


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Global Currency part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       GlobalCurrency,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInGlobalCurrency
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_ksl )     as CarryFwdBalanceAmtInGlobalCrcy, //Carry Forward Balance in Global Currency

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInGlobalCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInGlobalCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_hsl )        as PrevPerdYTDAmountInGlobalCrcy, //Previous period Year to Date Amount in Global Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInGlobalCurrency
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInGlobalCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInGlobalCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StartingBalanceAmtInGlobalCrcy, //Starting Balance in Global Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInGlobalCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInGlobalCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end                                  as AmountInGlobalCurrency, //Current Period Balance in Global Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInGlobalCurrency
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
                AmountInGlobalCurrency
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInGlobalCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalanceAmtInGlobalCrcy, //Ending Balance in Global Currency


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInGlobalCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInGlobalCurrency
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YearToDateAmountInGlobalCrcy, //Year to Date Amount in Global Currency

       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 1 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency1,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInFreeDefinedCurrency1
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_osl )     as CarryFwdBalAmountInFDCrcy1, //Carry Forward Balance in Free Defined Currency 1

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency1
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency1
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_hsl )        as PrevPerdYTDAmountInFDCrcy1, //Previous period Year to Date Amount in Free Defined Currency 1


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency1
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency1
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency1
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StrtgBalAmtInFreeDfndCrcy1, //Starting Balance in Free Defined Currency 1


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency1
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency1
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end                                  as AmountInFreeDefinedCurrency1, //Current Period Balance in Free Defined Currency 1


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency1
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
                AmountInFreeDefinedCurrency1
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency1
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalAmtInFreeDfndCrcy1, //Ending Balance in Free Defined Currency 1


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency1
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency1
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YearToDateAmountInFDCrcy1, //Year to Date Amount in Free Defined Currency 1


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 2 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency2,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInFreeDefinedCurrency2
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_vsl )     as CarryFwdBalAmountInFDCrcy2, //Carry Forward Balance in Free Defined Currency 2

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency2
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency2
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_hsl )        as PrevPerdYTDAmountInFDCrcy2, //Previous period Year to Date Amount in Free Defined Currency 2


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency2
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency2
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency2
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StrtgBalAmtInFreeDfndCrcy2, //Starting Balance in Free Defined Currency 2


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency2
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency2
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end                                  as AmountInFreeDefinedCurrency2, //Current Period Balance in Free Defined Currency 2


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency2
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
                AmountInFreeDefinedCurrency2
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency2
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalAmtInFreeDfndCrcy2, //Ending Balance in Free Defined Currency 2


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency2
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency2
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YearToDateAmountInFDCrcy2, //Year to Date Amount in Free Defined Currency 2

       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 3 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency3,
       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInFreeDefinedCurrency3
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_bsl )     as CarryFwdBalAmountInFDCrcy3, //Carry Forward Balance in Free Defined Currency 3

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency3
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency3
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_hsl )        as PrevPerdYTDAmountInFDCrcy3, //Previous period Year to Date Amount in Free Defined Currency 3


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency3
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency3
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency3
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StrtgBalAmtInFreeDfndCrcy3, //Starting Balance in Free Defined Currency 3


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency3
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency3
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end                                  as AmountInFreeDefinedCurrency3, //Current Period Balance in Free Defined Currency 3


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency3
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
                AmountInFreeDefinedCurrency3
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency3
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalAmtInFreeDfndCrcy3, //Ending Balance in Free Defined Currency 3


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency3
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency3
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YearToDateAmountInFDCrcy3, //Year to Date Amount in Free Defined Currency 3

       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 4 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency4,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInFreeDefinedCurrency4
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_csl )     as CarryFwdBalAmountInFDCrcy4, //Carry Forward Balance in Free Defined Currency 4

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency4
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency4
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_hsl )        as PrevPerdYTDAmountInFDCrcy4, //Previous period Year to Date Amount in Free Defined Currency 4


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency4
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency4
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency4
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StrtgBalAmtInFreeDfndCrcy4, //Starting Balance in in Free Defined Currency 4


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency4
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency4
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end                                  as AmountInFreeDefinedCurrency4, //Current Period Balance in Free Defined Currency 4


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency4
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
                AmountInFreeDefinedCurrency4
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency4
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalAmtInFreeDfndCrcy4, //Ending Balance in Free Defined Currency 4


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency4
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency4
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YearToDateAmountInFDCrcy4, //Year to Date Amount in Free Defined Currency 4

       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 5 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency5,

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInFreeDefinedCurrency5
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_dsl )     as CarryFwdBalAmountInFDCrcy5, //Carry Forward Balance in Free Defined Currency 5

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency5
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency5
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_hsl )        as PrevPerdYTDAmountInFDCrcy5, //Previous period Year to Date Amount in Free Defined Currency 5


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInCompanyCodeCurrency
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency5
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency5
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StrtgBalAmtInFreeDfndCrcy5, //Starting Balance in Free Defined Currency 5


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency5
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency5
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end                                  as AmountInFreeDefinedCurrency5, //Current Period Balance in Free Defined Currency 5


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency5
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
                AmountInFreeDefinedCurrency5
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency5
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalAmtInFreeDfndCrcy5, //Ending Balance in Free Defined Currency 5

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency5
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency5
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YearToDateAmountInFDCrcy5, //Year to Date Amount in Free Defined Currency 5

       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 6 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency6,
       @DefaultAggregation: #SUM

       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInFreeDefinedCurrency6
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_esl )     as CarryFwdBalAmountInFDCrcy6, //Carry Forward Balance in Free Defined Currency 6

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency6
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency6
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_hsl )        as PrevPerdYTDAmountInFDCrcy6, //Previous period Year to Date Amount in Free Defined Currency 6


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency6
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency6
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency6
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StrtgBalAmtInFreeDfndCrcy6, //Starting Balance in Free Defined Currency 6


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency6
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency6
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end                                  as AmountInFreeDefinedCurrency6, //Current Period Balance in Free Defined Currency 6


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency6
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
                AmountInFreeDefinedCurrency6
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency6
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalAmtInFreeDfndCrcy6, //Ending Balance in Free Defined Currency 6


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency6
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency6
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YearToDateAmountInFDCrcy6, //Year to Date Amount in Free Defined Currency 6

       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 7 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency7,

       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInFreeDefinedCurrency7
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_fsl )     as CarryFwdBalAmountInFDCrcy7, //Carry Forward Balance in Free Defined Currency 7

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency7
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency7
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_hsl )        as PrevPerdYTDAmountInFDCrcy7, //Previous period Year to Date Amount in Free Defined Currency 7


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency7
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency7
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency7
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StrtgBalAmtInFreeDfndCrcy7, //Starting Balance in Free Defined Currency 7


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency7
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency7
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end                                  as AmountInFreeDefinedCurrency7, //Current Period Balance in Free Defined Currency 7


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency7
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
                AmountInFreeDefinedCurrency7
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency7
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalAmtInFreeDfndCrcy7, //Ending Balance in Free Defined Currency 7


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency7
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency7
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YearToDateAmountInFDCrcy7, //Year to Date Amount in Free Defined Currency 7

       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       //Free Defined Currency 8 part
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       @Semantics.currencyCode:true
       FreeDefinedCurrency8,

       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       cast( case FiscalPeriod
               when '000'
                 then AmountInFreeDefinedCurrency8
               else cast( '0' as abap.curr( 23,2))
              end as zde_glo_cfwd_bal_gsl )     as CarryFwdBalAmountInFDCrcy8, //Carry Forward Balance in Free Defined Currency 8

       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency8
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency8
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as  zde_glo_ytd_bal_hsl )        as PrevPerdYTDAmountInFDCrcy8, //Previous period Year to Date Amount in Free Defined Currency 8


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       cast(case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency8
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate < $parameters.P_FromPostingDate
                   then AmountInFreeDefinedCurrency8
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod < $parameters.P_FromFiscalPeriod
                   then AmountInFreeDefinedCurrency8
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_fis_start_bal_hsl )       as StrtgBalAmtInFreeDfndCrcy8, //Starting Balance in Free Defined Currency 8


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate >= $parameters.P_FromPostingDate and PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency8
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod >= $parameters.P_FromFiscalPeriod and  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency8
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end                                  as AmountInFreeDefinedCurrency8, //Current Period Balance in Free Defined Currency 8


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       cast( case FiscalPeriod
         when '000'
         then AmountInFreeDefinedCurrency8
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
                AmountInFreeDefinedCurrency8
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency8
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as   zde_fis_end_bal_hsl )       as EndingBalAmtInFreeDfndCrcy8, //Ending Balance in Free Defined Currency 8


       @DefaultAggregation: #SUM
       @Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} }
       cast( case FiscalPeriod
         when '000'
         then cast( '0' as abap.curr( 23,2))
         else
           case $parameters.P_FromFiscalPeriod
             when '000'
             then
               case
                 when PostingDate <= $parameters.P_ToPostingDate
                   then AmountInFreeDefinedCurrency8
                 else cast( '0' as abap.curr( 23,2))
               end
             else
               case
                 when  FiscalPeriod <= $parameters.P_ToFiscalPeriod
                   then AmountInFreeDefinedCurrency8
                 else cast( '0' as abap.curr( 23,2))
               end
           end
       end as zde_glo_cytd_bal_hsl )        as YearToDateAmountInFDCrcy8, //Year to Date Amount in Free Defined Currency 8


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
