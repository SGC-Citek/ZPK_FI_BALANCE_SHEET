@AbapCatalog.sqlViewName: 'ZSQFINSTMNTSTRU2'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial Statement Structure 2'
define view zi_finstmnt_structure2
  with parameters
    @EndUserText.label: 'Alternative Account'
    P_AlternativeGLAccount : zde_figlmx_prim

  as select from zi_finstmnt_structure as FSV

{
  key FSV.FinancialStatementHierarchy                    as FinancialStatementHierarchy,
  key FSV.CompanyCode                                    as CompanyCode,
  key FSV.HierarchyNode                                  as HierarchyNode,
  key FSV.ChartOfAccounts                                as ChartOfAccounts,
  key FSV.HierarchyVersion                               as HierarchyVersion,
  key FSV.ValidityEndDate                                as ValidityEndDate,
      FSV.ValidityStartDate                              as ValidityStartDate,
      FSV.FinancialStatementNodeType                     as FinancialStatementNodeType,
      ltrim(ParentNode, '0')                             as FinancialStatementItem,
      FSV.OperationalGLAccount                           as OperationalGLAccount,
      FSV.GLAccount                                      as GLAccount,
      FSV._GLAccountText.GLAccountLongName               as GLAccountInfo,
      FSV.CountryChartOfAccounts                         as CountryChartOfAccounts,
      //FSV.MaintenanceLanguage                            as MaintenanceLanguage,
      FSV._GLAccountInChartOfAccounts.GLAccountGroup     as GLAccountGroup,
      FSV.VATRegistration                                as VATRegistration,
      substring(_ParentNodeText.HierarchyNodeText, 1, 1) as GLAccountType,
      FSV.OperationalChartOfAccounts                     as OperationalChartOfAccounts,

      _GLAccountInChartOfAccounts


}
where
      FSV.AlternativeGLAccountIsUsed = $parameters.P_AlternativeGLAccount
  and FSV.GLAccount                  is not initial
