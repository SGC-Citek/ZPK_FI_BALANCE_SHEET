class zcl_fi_balance_sheet definition
  public
  final
  create public.
  public section.
    interfaces:
      if_rap_query_provider.
  private section.
ENDCLASS.



CLASS ZCL_FI_BALANCE_SHEET IMPLEMENTATION.


  method if_rap_query_provider~select.
    case io_request->get_entity_id( ).
      when 'ZC_FI_BALANCE_SHEET'.
        zcl_fi_balance_sheet_manage=>get_instance( )->get_data(
            exporting io_request = io_request
            importing et_data    = data(lt_data) ).

        if io_request->is_data_requested( ).
          io_response->set_data( lt_data ).
        endif.
        if io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( lt_data ) ).
        endif.
    endcase.
  endmethod.
ENDCLASS.
