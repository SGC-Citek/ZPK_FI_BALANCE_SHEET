@AbapCatalog.sqlViewName: 'ZSQFINSTMNTSTRUC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial Statement Structure'
define view zi_finstmnt_structure
  as select from I_GLAccountHierarchyNode as FSV

    inner join   I_CompanyCode            on I_CompanyCode.ChartOfAccounts = FSV.ChartOfAccounts

    inner join   I_GLAccountInCompanyCode on  I_GLAccountInCompanyCode.CompanyCode = I_CompanyCode.CompanyCode
                                          and I_GLAccountInCompanyCode.GLAccount   = FSV.GLAccount

  //  association [0..*] to R_HierRuntimeRprstnAttrib    as _Language                   on  $projection.FinancialStatementHierarchy = _Language.HierarchyID
  //                                                                                    and $projection.ValidityEndDate             = _Language.ValidityEndDate
  //                                                                                    and _Language.HierarchyAttributeName        = 'LANGUAGE'
  //
  association [0..1] to I_GLAccountTextRawData       as _GLAccountText              on  $projection.OperationalChartOfAccounts = _GLAccountText.ChartOfAccounts
                                                                                    and $projection.GLAccount                  = _GLAccountText.GLAccount
                                                                                    and $projection.MaintenanceLanguage        = _GLAccountText.Language

  association [0..1] to I_GLAccountHierarchyNodeT    as _ParentNodeText             on  $projection.FinancialStatementHierarchy = _ParentNodeText.GLAccountHierarchy
                                                                                    and $projection.ParentNode                  = _ParentNodeText.HierarchyNode
                                                                                    and $projection.ValidityEndDate             = _ParentNodeText.ValidityEndDate
                                                                                    and $projection.MaintenanceLanguage         = _ParentNodeText.Language

  association [0..1] to I_GLAccountInChartOfAccounts as _GLAccountInChartOfAccounts on  $projection.OperationalChartOfAccounts = _GLAccountInChartOfAccounts.ChartOfAccounts
                                                                                    and $projection.GLAccount                  = _GLAccountInChartOfAccounts.GLAccount

{
  key FSV.GLAccountHierarchy               as FinancialStatementHierarchy,
  key I_CompanyCode.CompanyCode            as CompanyCode,
  key FSV.HierarchyNode                    as HierarchyNode,
  key FSV.ChartOfAccounts                  as ChartOfAccounts,
  key FSV.ValidityEndDate                  as ValidityEndDate,
  key FSV.HierarchyVersion                 as HierarchyVersion,
      FSV.ChartOfAccounts                  as OperationalChartOfAccounts, //Chart of Accounts directly from the FSV, in case it is a Country CoA. Is used to get the correct text from each GL.
      FSV.ValidityStartDate                as ValidityStartDate,
      FSV.NodeType                         as FinancialStatementNodeType,
      FSV.ParentNode                       as ParentNode,
      FSV.GLAccount                        as OperationalGLAccount,
      FSV.GLAccount                        as GLAccount,
      I_CompanyCode.CountryChartOfAccounts as CountryChartOfAccounts,
      'E'                                  as MaintenanceLanguage,
      I_CompanyCode.VATRegistration        as VATRegistration,
      ''                                   as AlternativeGLAccountIsUsed,

      _GLAccountInChartOfAccounts,
      _ParentNodeText,
      _GLAccountText

}
where
      FSV.NodeType   =  'L'
  and FSV.ParentNode <> '00NOTASSGND'

union all select from I_GLAccountHierarchyNode as FSV

  inner join          I_CompanyCode                                           on I_CompanyCode.CountryChartOfAccounts = FSV.ChartOfAccounts

  inner join          I_GLAccountInCompanyCode as AlternativeGLAccountDetails on  AlternativeGLAccountDetails.CompanyCode          = I_CompanyCode.CompanyCode
                                                                              and AlternativeGLAccountDetails.AlternativeGLAccount = FSV.GLAccount

//association [0..*] to R_HierRuntimeRprstnAttrib    as _Language                   on  $projection.FinancialStatementHierarchy = _Language.HierarchyID
//                                                                                  and $projection.ValidityEndDate             = _Language.ValidityEndDate
//                                                                                  and _Language.HierarchyAttributeName        = 'LANGUAGE'
//
association [0..1] to I_GLAccountTextRawData       as _GLAccountText              on  $projection.OperationalChartOfAccounts = _GLAccountText.ChartOfAccounts
                                                                                  and $projection.GLAccount                  = _GLAccountText.GLAccount
                                                                                  and $projection.MaintenanceLanguage        = _GLAccountText.Language

association [0..1] to I_GLAccountHierarchyNodeT    as _ParentNodeText             on  $projection.FinancialStatementHierarchy = _ParentNodeText.GLAccountHierarchy
                                                                                  and $projection.ParentNode                  = _ParentNodeText.HierarchyNode
                                                                                  and $projection.ValidityEndDate             = _ParentNodeText.ValidityEndDate
                                                                                  and $projection.MaintenanceLanguage         = _ParentNodeText.Language

association [0..1] to I_GLAccountInChartOfAccounts as _GLAccountInChartOfAccounts on  $projection.OperationalChartOfAccounts = _GLAccountInChartOfAccounts.ChartOfAccounts
                                                                                  and $projection.GLAccount                  = _GLAccountInChartOfAccounts.GLAccount
{
  key FSV.GLAccountHierarchy                as FinancialStatementHierarchy,
  key I_CompanyCode.CompanyCode             as CompanyCode,
  key FSV.HierarchyNode                     as HierarchyNode,
  key I_CompanyCode.ChartOfAccounts         as ChartOfAccounts,
  key FSV.ValidityEndDate                   as ValidityEndDate,
  key FSV.HierarchyVersion                  as HierarchyVersion,
      FSV.ChartOfAccounts                   as OperationalChartOfAccounts, //Chart of Accounts directly from the FSV, in case it is a Country CoA. Is used to get the correct text from each GL.
      FSV.ValidityStartDate                 as ValidityStartDate,
      FSV.NodeType                          as FinancialStatementNodeType,
      FSV.ParentNode                        as ParentNode,
      AlternativeGLAccountDetails.GLAccount as OperationalGLAccount,
      FSV.GLAccount                         as GLAccount,
      I_CompanyCode.CountryChartOfAccounts  as CountryChartOfAccounts,
      'E'                                   as MaintenanceLanguage,
      I_CompanyCode.VATRegistration         as VATRegistration,
      'X'                                   as AlternativeGLAccountIsUsed,

      _GLAccountInChartOfAccounts,
      _ParentNodeText,
      _GLAccountText

}
where
      FSV.NodeType   =  'L'
  and FSV.ParentNode <> '00NOTASSGND'
