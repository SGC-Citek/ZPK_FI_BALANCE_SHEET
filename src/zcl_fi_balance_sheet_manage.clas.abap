CLASS zcl_fi_balance_sheet_manage DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
    DATA: gt_data TYPE TABLE OF zc_fi_balance_sheet.
    CLASS-METHODS:
      get_instance
        RETURNING
          VALUE(ro_instance) TYPE REF TO zcl_fi_balance_sheet_manage,
      get_data
        IMPORTING io_request TYPE REF TO if_rap_query_request
        EXPORTING et_data    LIKE gt_data.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: instance TYPE REF TO zcl_fi_balance_sheet_manage.
    CLASS-METHODS:
      get_data_db
        IMPORTING io_request TYPE REF TO if_rap_query_request
        EXPORTING et_data    LIKE gt_data.
ENDCLASS.



CLASS ZCL_FI_BALANCE_SHEET_MANAGE IMPLEMENTATION.


  METHOD get_data.
    " get list field requested ----------------------
    DATA(lt_reqs_element) = io_request->get_requested_elements( ).
    DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).
    IF lt_aggr_element IS NOT INITIAL.
      LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<lfs_aggr_elements>).
        DELETE lt_reqs_element WHERE table_line = <lfs_aggr_elements>-result_element.
        DATA(lv_aggr) = |{ <lfs_aggr_elements>-aggregation_method }( { <lfs_aggr_elements>-input_element } ) as { <lfs_aggr_elements>-result_element }|.
        APPEND lv_aggr TO lt_reqs_element.
      ENDLOOP.
    ENDIF.

    DATA(lv_reqs_element) = concat_lines_of( table = lt_reqs_element sep = `, ` ).
    " get list field requested ----------------------

    " get list field ordered ------------------------
    DATA(lt_sort) = io_request->get_sort_elements( ).

    DATA(lt_sort_criteria) = VALUE string_table( FOR ls_sort IN lt_sort ( ls_sort-element_name && COND #( WHEN ls_sort-descending = abap_true THEN ` descending`
                                                                                                                                              ELSE ` ascending` ) ) ).

    DATA(lv_sort_element) = COND #( WHEN lt_sort_criteria IS INITIAL THEN `fs_item` ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).
    " get list field ordered ------------------------

    " get range of row data -------------------------
    DATA(lv_top)      = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)     = io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                ELSE lv_top ).
    IF lv_max_rows = -1 .
      lv_max_rows = 1.
    ENDIF.
    " get range of row data -------------------------

    "get data --------------------------------------
    DATA: lv_fieldname   TYPE c LENGTH 30,
          lv_count       TYPE int1,
          lv_prev_serial TYPE c LENGTH 18.

    get_data_db( EXPORTING io_request = io_request IMPORTING et_data = DATA(lt_data) ).

    SELECT (lv_reqs_element)
    FROM @lt_data AS data
    ORDER BY (lv_sort_element)
    INTO CORRESPONDING FIELDS OF TABLE @et_data
    OFFSET @lv_skip UP TO @lv_max_rows ROWS.
    "get data --------------------------------------
  ENDMETHOD.


  METHOD get_data_db.
    TYPES lv_fiscal_year   TYPE n LENGTH 4.
    TYPES lv_fiscal_period TYPE n LENGTH 2.
    DATA lv_bukrs              TYPE bukrs.
    DATA lv_ver_cf             TYPE zde_fi_fs_ver_cf.
    DATA lv_ledger             TYPE fins_ledger.
    DATA lv_fiscal_year        TYPE lv_fiscal_year.
    DATA lv_fiscal_period      TYPE lv_fiscal_period.
    DATA lv_fiscal_year_comp   TYPE lv_fiscal_year.
    DATA lv_fiscal_period_comp TYPE lv_fiscal_period.

    DATA lt_data               TYPE TABLE OF zc_fi_balance_sheet.

    " get filter by parameter -----------------------
    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option). " TODO: variable is assigned but never used (ABAP cleaner)
    ENDTRY.
    IF lt_filter_cond IS NOT INITIAL.
      LOOP AT lt_filter_cond REFERENCE INTO DATA(ls_filter_cond).
        CASE ls_filter_cond->name.
          WHEN 'COMPANY_CODE'.
            lv_bukrs         = ls_filter_cond->range[ 1 ]-low.
          WHEN 'FS_VER_CF'.
            lv_ver_cf        = ls_filter_cond->range[ 1 ]-low.
          WHEN 'LEDGER'.
            lv_ledger        = ls_filter_cond->range[ 1 ]-low.
          WHEN 'PERIOD_YEAR'.
            lv_fiscal_year   = ls_filter_cond->range[ 1 ]-low+0(4).
            lv_fiscal_period = ls_filter_cond->range[ 1 ]-low+4(2).
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    " get filter by parameter -----------------------

    SELECT i_financialstatementhiernode~HierarchyNode,
           i_financialstatementhiernode~ParentNode,
           i_financialstatementhiernode~HierarchyLevel,
           ztb_fi_fs_ver_cf~is_bold,
           ztb_fi_fs_ver_cf~is_nega,
           ztb_fi_fs_ver_cf~fs_note,
           ztb_fi_fs_ver_cf~fs_item_txt_vn,
           ztb_fi_fs_ver_cf~fs_item_txt_en,
           ztb_fi_fs_ver_cf~fs_hrynode,
           ztb_fi_fs_ver_cf~fs_item
      FROM I_FinancialStatementHierNode
             LEFT OUTER JOIN
               ztb_fi_fs_ver_cf ON  ztb_fi_fs_ver_cf~fs_ver_cf  = i_financialstatementhiernode~FinancialStatementHierarchy
                                AND ztb_fi_fs_ver_cf~fs_hrynode = i_financialstatementhiernode~HierarchyNode
      WHERE i_financialstatementhiernode~FinancialStatementHierarchy  = @lv_ver_cf
        AND i_financialstatementhiernode~HierarchyNode               <> '00NOTASSGND'
        AND i_financialstatementhiernode~ParentNode                  <> '00NOTASSGND'
        AND i_financialstatementhiernode~FinancialStatementNodeType   = 'I'
      INTO TABLE @DATA(lt_fshierval).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*    SELECT SINGLE
*      zi_organizationaddress~addresseename1    AS nameen,
*      zi_organizationaddress~addresseename2    AS namevi,
*      zi_organizationaddress~streetname        AS addressen1,
*      zi_organizationaddress~streetprefixname1 AS addressen2,
*      zi_organizationaddress~streetprefixname2 AS addressvi1,
*      zi_organizationaddress~streetsuffixname1 AS addressvi2,
*      zi_organizationaddress~streetsuffixname2 AS addressvi3,
*      i_companycode~vatregistration            AS taxcode
*      FROM i_companycode
*      INNER JOIN zi_organizationaddress ON zi_organizationaddress~addressid = i_companycode~addressid
*      WHERE i_companycode~companycode = @lv_bukrs
*      INTO @DATA(ls_organizationaddress).
*    IF sy-subrc EQ 0.
*      CONDENSE: ls_organizationaddress-nameen,
*                ls_organizationaddress-namevi,
*                ls_organizationaddress-addressen1,
*                ls_organizationaddress-addressen2,
*                ls_organizationaddress-addressvi1,
*                ls_organizationaddress-addressvi2,
*                ls_organizationaddress-addressvi3.
*    ENDIF.
    SELECT SINGLE longname,
                  address,
                  vatnumber
      FROM zcore_i_profile_companycode_v2
      WHERE companycode = @lv_bukrs
      INTO @DATA(ls_organizationaddress).
    IF sy-subrc = 0.
      CONDENSE: ls_organizationaddress-longname,
                ls_organizationaddress-address,
                ls_organizationaddress-vatnumber.
    ENDIF.

    LOOP AT lt_fshierval ASSIGNING FIELD-SYMBOL(<lfs_fshierval>).
      SHIFT <lfs_fshierval>-hierarchynode LEFT DELETING LEADING '0'.
      SHIFT <lfs_fshierval>-parentnode LEFT DELETING LEADING '0'.
      SHIFT <lfs_fshierval>-hierarchylevel LEFT DELETING LEADING '0'.
      SHIFT <lfs_fshierval>-fs_hrynode LEFT DELETING LEADING '0'.

      IF <lfs_fshierval>-fs_hrynode IS INITIAL.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( company_code   = lv_bukrs
                      fs_ver_cf      = lv_ver_cf
                      ledger         = lv_ledger
                      fs_hrynode     = <lfs_fshierval>-fs_hrynode
                      fs_item        = <lfs_fshierval>-fs_item
                      is_bold        = <lfs_fshierval>-is_bold
                      is_nega        = <lfs_fshierval>-is_nega
                      fs_note        = <lfs_fshierval>-fs_note
                      fs_item_txt_vn = <lfs_fshierval>-fs_item_txt_vn
                      fs_item_txt_en = <lfs_fshierval>-fs_item_txt_en
*                      compnameen     = ls_organizationaddress-nameen
*                      compaddressen  = ls_organizationaddress-addressen1 && ` ` &&
*                                            ls_organizationaddress-addressen2
*                      compnamevi     = ls_organizationaddress-namevi
*                      compaddressvi  = ls_organizationaddress-addressvi1 && ` ` &&
*                                            ls_organizationaddress-addressvi2 && ` ` &&
*                                            ls_organizationaddress-addressvi3
*                      comptaxcode    = ls_organizationaddress-taxcode
                      compnameen     = ls_organizationaddress-longname
                      compaddressen  = ls_organizationaddress-address
                      compnamevi     = ls_organizationaddress-longname
                      compaddressvi  = ls_organizationaddress-address
                      comptaxcode    = ls_organizationaddress-vatnumber
                      currency       = 'VND'
                      period_year    = lv_fiscal_year && lv_fiscal_period )
             TO lt_data.
    ENDLOOP.

    SORT lt_fshierval BY HierarchyNode.
    SORT lt_data BY fs_hrynode.

    DATA lv_fromdate  TYPE dats.
    DATA lv_todate    TYPE dats.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_month_tmp TYPE n LENGTH 2.

    " from date
    IF lv_fiscal_period = 1.
      lv_fiscal_period_comp = 12.
      lv_fiscal_year_comp = lv_fiscal_year - 1.
    ELSE.
      lv_fiscal_period_comp = lv_fiscal_period - 1.
      lv_fiscal_year_comp = lv_fiscal_year.
    ENDIF.

    IF lv_fiscal_period_comp = 12.
      lv_month_tmp = 1.
    ELSE.
      lv_month_tmp = lv_fiscal_period_comp + 1.
    ENDIF.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" get compare period
    SELECT SINGLE FirstDayOfMonthDate
      FROM i_yearmonth
      WHERE CalendarYear  = @lv_fiscal_year_comp
        AND CalendarMonth = @lv_fiscal_period_comp
      INTO @lv_fromdate.

    SELECT SINGLE LastDayOfMonthDate
      FROM i_yearmonth
      WHERE CalendarYear  = @lv_fiscal_year_comp
        AND CalendarMonth = @lv_fiscal_period_comp
      INTO @lv_todate.

    SELECT CompanyCode,
           Ledger,
           FiscalYear,
           FinancialStatementVariant,
           HierarchyNodeUniqueID,
           FinancialStatementItem,
           CompanyCodeCurrency,
           SUM( EndingBalanceAmtInCoCodeCrcy )   AS EndingBalanceAmtInCoCodeCrcy
      FROM zi_finstmnt_rptg_cube( P_FromPostingDate           = @lv_fromdate,
                                  P_ToPostingDate             = @lv_todate,
                                  P_FinancialStatementVariant = @lv_ver_cf,
                                  P_AlternativeGLAccount      = ' ' )
      WHERE CompanyCode = @lv_bukrs
        AND Ledger      = @lv_ledger
      GROUP BY CompanyCode,
               Ledger,
               FiscalYear,
               FinancialStatementVariant,
               HierarchyNodeUniqueID,
               FinancialStatementItem,
               CompanyCodeCurrency
      INTO TABLE @DATA(lt_data_dauki).

    SELECT HierarchyNodeUniqueID,
           FinancialStatementItem,
           SUM( EndingBalanceAmtInCoCodeCrcy ) AS amount
      FROM @lt_data_dauki AS data
      GROUP BY HierarchyNodeUniqueID,
               FinancialStatementItem
         " TODO: variable is assigned but never used (ABAP cleaner)
      INTO TABLE @DATA(lt_gr_dauki).
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" get compare period

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" get current period

    SELECT SINGLE FirstDayOfMonthDate
      FROM i_yearmonth
      WHERE CalendarYear  = @lv_fiscal_year
        AND CalendarMonth = @lv_fiscal_period
      INTO @lv_fromdate.

    " to date
    SELECT SINGLE LastDayOfMonthDate
      FROM i_yearmonth
      WHERE CalendarYear  = @lv_fiscal_year
        AND CalendarMonth = @lv_fiscal_period
      INTO @lv_todate.

    SELECT CompanyCode,
           Ledger,
           FiscalYear,
           FinancialStatementVariant,
           HierarchyNodeUniqueID,
           FinancialStatementItem,
           CompanyCodeCurrency,
           sum( EndingBalanceAmtInCoCodeCrcy ) as EndingBalanceAmtInCoCodeCrcy
      FROM zi_finstmnt_rptg_cube( P_FromPostingDate           = @lv_fromdate,
                                  P_ToPostingDate             = @lv_todate,
                                  P_FinancialStatementVariant = @lv_ver_cf,
                                  P_AlternativeGLAccount      = ' ' )
      WHERE CompanyCode = @lv_bukrs
        AND Ledger      = @lv_ledger
      GROUP BY CompanyCode,
               Ledger,
               FiscalYear,
               FinancialStatementVariant,
               HierarchyNodeUniqueID,
               FinancialStatementItem,
               CompanyCodeCurrency
      INTO TABLE @DATA(lt_data_cuoiki).

    SELECT HierarchyNodeUniqueID,
           FinancialStatementItem,
           SUM( EndingBalanceAmtInCoCodeCrcy ) AS amount
      FROM @lt_data_cuoiki AS data
      GROUP BY HierarchyNodeUniqueID,
               FinancialStatementItem
   " TODO: variable is assigned but never used (ABAP cleaner)
      INTO TABLE @DATA(lt_gr_cuoiki).

*    SELECT cuoiki~CompanyCode,
*           cuoiki~Ledger,
*           cuoiki~FiscalYear,
*           cuoiki~FinancialStatementVariant,
*           cuoiki~HierarchyNodeUniqueID,
*           cuoiki~FinancialStatementItem,
*           cuoiki~CompanyCodeCurrency,
*           cuoiki~EndingBalanceAmtInCoCodeCrcy,
*           dauki~EndingBalanceAmtInCoCodeCrcy  AS StartingBalanceAmtInCoCodeCrcy
*      FROM zi_finstmnt_rptg_cube( P_FromPostingDate           = @lv_fromdate,
*                                  P_ToPostingDate             = @lv_todate,
*                                  P_FinancialStatementVariant = @lv_ver_cf,
*                                  P_AlternativeGLAccount      = ' ' ) AS cuoiki
*             LEFT JOIN
*               @lt_data_dauki AS dauki ON dauki~HierarchyNodeUniqueID = cuoiki~HierarchyNodeUniqueID AND dauki~FinancialStatementItem = cuoiki~FinancialStatementItem
*      WHERE cuoiki~CompanyCode = @lv_bukrs
*        AND cuoiki~Ledger      = @lv_ledger
*      INTO TABLE @DATA(lt_trans).

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" get current period

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_data_dauki INTO DATA(ls_trans).
      READ TABLE lt_fshierval INTO DATA(ls_fshierval)
           WITH KEY HierarchyNode = ls_trans-FinancialStatementItem BINARY SEARCH.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>)
           WITH KEY fs_hrynode = ls_fshierval-fs_hrynode BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_data>-val_prev_ped += ls_trans-EndingBalanceAmtInCoCodeCrcy.
*        <lfs_data>-val_prev_ped += ls_trans-StartingBalanceAmtInCoCodeCrcy.
      ELSE.

      ENDIF.
      DO ls_fshierval-hierarchylevel - 1 TIMES.
        READ TABLE lt_fshierval INTO ls_fshierval
             WITH KEY HierarchyNode = ls_fshierval-parentnode BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE lt_data ASSIGNING <lfs_data>
               WITH KEY fs_hrynode = ls_fshierval-fs_hrynode BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_data>-val_prev_ped += ls_trans-EndingBalanceAmtInCoCodeCrcy.
*            <lfs_data>-val_prev_ped += ls_trans-StartingBalanceAmtInCoCodeCrcy.
          ELSE.

          ENDIF.
        ENDIF.
      ENDDO.
    ENDLOOP.





    LOOP AT lt_data_cuoiki INTO ls_trans.
      READ TABLE lt_fshierval INTO ls_fshierval
           WITH KEY HierarchyNode = ls_trans-FinancialStatementItem BINARY SEARCH.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_data ASSIGNING <lfs_data>
           WITH KEY fs_hrynode = ls_fshierval-fs_hrynode BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_data>-val_curr_ped += ls_trans-EndingBalanceAmtInCoCodeCrcy.
*        <lfs_data>-val_prev_ped += ls_trans-StartingBalanceAmtInCoCodeCrcy.
      ELSE.

      ENDIF.
      DO ls_fshierval-hierarchylevel - 1 TIMES.
        READ TABLE lt_fshierval INTO ls_fshierval
             WITH KEY HierarchyNode = ls_fshierval-parentnode BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE lt_data ASSIGNING <lfs_data>
               WITH KEY fs_hrynode = ls_fshierval-fs_hrynode BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_data>-val_curr_ped += ls_trans-EndingBalanceAmtInCoCodeCrcy.
*            <lfs_data>-val_prev_ped += ls_trans-StartingBalanceAmtInCoCodeCrcy.
          ELSE.

          ENDIF.
        ENDIF.
      ENDDO.
    ENDLOOP.

    LOOP AT lt_data ASSIGNING <lfs_data>.
      IF <lfs_data>-is_nega = 'X'.
        <lfs_data>-val_curr_ped *= -1.
        <lfs_data>-val_prev_ped *= -1.
      ENDIF.
    ENDLOOP.
*
    SORT lt_data BY fs_item.

    et_data = lt_data.
  ENDMETHOD.


  METHOD get_instance.
    IF instance IS INITIAL.
      CREATE OBJECT instance.
    ENDIF.
    ro_instance = instance.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA: lo_request TYPE REF TO if_rap_query_request.
    get_data_db( EXPORTING io_request = lo_request IMPORTING et_data = DATA(lt_data) ).
  ENDMETHOD.
ENDCLASS.
