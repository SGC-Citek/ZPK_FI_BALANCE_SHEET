@EndUserText.label: 'Balance Sheet'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FI_BALANCE_SHEET'
@UI: {
    headerInfo: {
        typeName: 'Balance Sheet',
        typeNamePlural: 'Balance Sheet',
        title: {
            type: #STANDARD,
            label: 'Balance Sheet'
        }
    }
}
define root custom entity ZC_FI_BALANCE_SHEET
{
      @Consumption   : {
      valueHelpDefinition: [{ entity: {
      name           : 'I_CompanyCodeStdVH',
      element        : 'CompanyCode'
      } }]
      }
      @UI.selectionField: [{ position: 10 }]
      //      @Consumption.filter.defaultValue: '1000'
  key company_code   : bukrs;
      @Consumption   : {
      valueHelpDefinition: [{ entity: {
      name           : 'ZI_GLAccountHierarchyVH',
      element        : 'GLAccountHierarchy'
      } }]
      }
      @UI.selectionField: [{ position: 20 }]
      //      @Consumption.filter.defaultValue: 'ZBS1'
  key fs_ver_cf      : zde_fi_fs_ver_cf;
      @Consumption   : {
      valueHelpDefinition: [{ entity: {
      name           : 'ZI_LedgerVH',
      element        : 'Ledger'
      } }]
      }
      @UI.selectionField: [{ position: 30 }]
      //      @Consumption.filter.defaultValue: '0L'
  key ledger         : fins_ledger;
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Period Year'
      @Consumption.filter.hidden: true
  key period_year    : char6;
  key fs_hrynode     : zde_hrynode;
      @EndUserText.label: 'Period'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.hidden: true
      period         : datum;
      @EndUserText.label: 'Test Period'
      @UI.selectionField: [{ position: 40 }]
      test_period    : char7;
      @Consumption.filter.hidden: true
      fs_item_txt_vn : zde_fi_fs_item_txt_vn;
      @Consumption.filter.hidden: true
      fs_item_txt_en : zde_fi_fs_item_txt_en;
      @Consumption.filter.hidden: true
      fs_item        : zde_fi_fs_item;
      @Consumption.filter.hidden: true
      is_bold        : zde_fi_is_bold;
      @Consumption.filter.hidden: true
      is_nega        : zde_fi_is_negative_posting;
      @Consumption.filter.hidden: true
      fs_note        : zde_fi_fs_note;
      @Consumption.filter.hidden: true
      currency       : waers;
      @Semantics.amount.currencyCode: 'currency'
      @Consumption.filter.hidden: true
      val_curr_ped   : zde_fis_wsl;
      @Semantics.amount.currencyCode: 'currency'
      @Consumption.filter.hidden: true
      val_prev_ped   : zde_fis_wsl;
      @Consumption.filter.hidden: true
      CompNameVI     : char100;
      @Consumption.filter.hidden: true
      CompAddressVI  : char100;
      @Consumption.filter.hidden: true
      CompNameEN     : char100;
      @Consumption.filter.hidden: true
      CompAddressEN  : char100;
      @Consumption.filter.hidden: true
      CompTaxCode    : char100;
      language       : abap.char(1);
}
