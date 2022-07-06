class ZCL_IM_CORE_RMS_OPUNIT definition
  public
  final
  create public .

public section.

  interfaces /SCWM/IF_EX_CORE_RMS_OPUNIT .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_CORE_RMS_OPUNIT IMPLEMENTATION.


  METHOD /scwm/if_ex_core_rms_opunit~opunit.

    DATA: lt_cont  TYPE /scwm/tt_packspec_nested.

    BREAK-POINT ID zewmdevbook_446.
    "Set standard value
    ev_opunit = is_ltap-altme.
    "Check context – only pick-WTs are considered
    CHECK is_ltap-trart CA wmegc_trart_pick. "'2'
    "Source-HU must be supplied
    IF is_ltap-vlenr IS INITIAL OR
    is_ltap-flghuto = abap_true.
      RETURN.
    ENDIF.
    "Get data of source-HU
    /scwm/cl_wm_packing=>set_global_fields( iv_lgnum = is_ltap-lgnum ).
    DATA(lo_pack) = NEW /scwm/cl_wm_packing( ).
    lo_pack->get_hu(
      EXPORTING
        iv_guid_hu = is_ltap-sguid_hu
      IMPORTING
        es_huhdr = DATA(ls_huhdr) ).
    IF NOT sy-subrc IS INITIAL.
      io_log->add_message( ip_row   = iv_row
                           ip_field = 'ALTME' ).
      RETURN.
    ENDIF.
    "HU must contain a packaging specification
    IF ls_huhdr-ps_guid IS INITIAL.
      RETURN.
    ENDIF.
    "Get packaging specification
    CALL FUNCTION '/SCWM/PS_PACKSPEC_GET'
      EXPORTING
        iv_guid_ps          = ls_huhdr-ps_guid
      IMPORTING
        et_packspec_content = lt_cont
      EXCEPTIONS
        OTHERS              = 99.
    IF NOT sy-subrc IS INITIAL.
      io_log->add_message( ip_row   = iv_row
                           ip_field = 'ALTME' ).
      RETURN.
    ENDIF.
    DATA(pscont) = VALUE #( lt_cont[ 1 ] OPTIONAL ).
    IF pscont IS INITIAL.
      RETURN.
    ENDIF.
    SORT pscont-levels BY level_seq.
    LOOP AT pscont-levels
    ASSIGNING FIELD-SYMBOL(<pslevel>).
      IF is_ltap-vsolm < <pslevel>-total_quan.
        EXIT.
      ENDIF.
      CHECK NOT <pslevel>-operat_unit IS INITIAL.
      "Set operative unit of measure
      ev_opunit = <pslevel>-operat_unit.
      "Operative unit of measure &1 set.
      MESSAGE s001(zewmdevbook_446) WITH ev_opunit
      INTO DATA(lv_msg).
    ENDLOOP.
    IF NOT lv_msg IS INITIAL.
      io_log->add_message( ip_row = iv_row ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
