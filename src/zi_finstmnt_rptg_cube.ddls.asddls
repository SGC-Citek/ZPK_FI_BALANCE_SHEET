@AbapCatalog.sqlViewName: 'ZSQLIFINSTATRPTG'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial Statement Reporting Information'
define view zi_finstmnt_rptg_cube

  with parameters
    @EndUserText.label: 'From Posting Date'
    P_FromPostingDate           : zde_fis_budat_from,
    @EndUserText.label: 'To Posting Date'
    P_ToPostingDate             : zde_fis_budat_to,
    @EndUserText.label: 'Financial Statement Variant'
    P_FinancialStatementVariant : zde_versn_011,
    @EndUserText.label: 'Alternative Account'
    P_AlternativeGLAccount      : zde_figlmx_prim

  as select from            zi_finstmnt_structure2( P_AlternativeGLAccount: $parameters.P_AlternativeGLAccount ) as FSV

    left outer to many join zi_finstmnt_trialbalitem(
                            P_FromPostingDate:  $parameters.P_FromPostingDate,
                            P_ToPostingDate:    $parameters.P_ToPostingDate,
                            P_FromFiscalPeriod: '000',
                            P_ToFiscalPeriod:   '000' )                                                          as GLAccountBalance on  GLAccountBalance.CompanyCode     = FSV.CompanyCode
                                                                                                                                     and GLAccountBalance.ChartOfAccounts = FSV.ChartOfAccounts
                                                                                                                                     and GLAccountBalance.GLAccount       = FSV.OperationalGLAccount

  association [1..1] to I_OperationalAcctgDocItem as _OperationalAcctgDocItem on  GLAccountBalance.CompanyCode            = _OperationalAcctgDocItem.CompanyCode
                                                                              and GLAccountBalance.FiscalYear             = _OperationalAcctgDocItem.FiscalYear
                                                                              and GLAccountBalance.AccountingDocument     = _OperationalAcctgDocItem.AccountingDocument
                                                                              and GLAccountBalance.AccountingDocumentItem = _OperationalAcctgDocItem.AccountingDocumentItem

{
  key FSV.HierarchyNode                                                        as HierarchyNodeUniqueID,
  key cast(FSV.FinancialStatementHierarchy as zde_versn_011)                   as FinancialStatementVariant,
  key FSV.ChartOfAccounts,
  key FSV.ValidityEndDate,
  key FSV.CompanyCode,
  key GLAccountBalance.Ledger,
  key GLAccountBalance.AccountingDocument,
  key cast( GLAccountBalance.FiscalYear as fis_gjahr_no_conv preserving type ) as FiscalYear,
  key GLAccountBalance.LedgerGLLineItem,
  key FSV.GLAccount,
      GLAccountBalance.AccountingDocumentItem,
      FSV.ValidityStartDate,
      _OperationalAcctgDocItem.BusinessPlace,
      cast(FSV.FinancialStatementItem as zde_ergsl)                            as FinancialStatementItem,
      GLAccountBalance.PostingDate,
      GLAccountBalance.FiscalPeriod,
      FSV.VATRegistration,
      FSV.GLAccountType,
      FSV.GLAccountInfo,
      FSV.GLAccountGroup,
      FSV.FinancialStatementNodeType,
  
      @Semantics.currencyCode: true
      GLAccountBalance.CompanyCodeCurrency                                     as CompanyCodeCurrency,
      @DefaultAggregation:#SUM
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      GLAccountBalance.StartingBalanceAmtInCoCodeCrcy                          as StartingBalanceAmtInCoCodeCrcy,
      @DefaultAggregation:#SUM
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      GLAccountBalance.DebitAmountInCoCodeCrcy                                 as DebitAmountInCoCodeCrcy,
      @DefaultAggregation:#SUM
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      GLAccountBalance.CreditAmountInCoCodeCrcy                                as CreditAmountInCoCodeCrcy,
      @DefaultAggregation: #SUM
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      GLAccountBalance.EndingBalanceAmtInCoCodeCrcy                            as EndingBalanceAmtInCoCodeCrcy
}
where
      FSV.FinancialStatementHierarchy = $parameters.P_FinancialStatementVariant
  and FSV.ValidityEndDate             >= $parameters.P_FromPostingDate
  and FSV.ValidityStartDate           <= $parameters.P_ToPostingDate
