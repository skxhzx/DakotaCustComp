     *  LT210     RF License plate tracking
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
500 M*      $pcmd        *PUTAWYA - Putaway - Put into slot (*PUTAWY2)
500 M*                                        After slot has been updated.
500 M*                   *PUTAWYB - Putaway - Put into slot (*PUTAWY2)
500 M*                                        Before slot has been updated.
500aA*                   *PUTAREA - Putaway - Put into area (non-slot)
500cA*                   *PUTSTFA - Putaway - Stuff into slot
500 M*                                        After slot has been updated.
500cA*                   *PUTSTFB - Putaway - Stuff into slot
500 M*                                        Before slot has been updated.
500 M*                   *PUTTRAN - Putaway - In transit (*PUTAWY1)
500 M*                   *PUTUNDO - Putaway - Undo (*PUTAWY0)
500 A*                   *PULDROP - Pull - Drop pallet to floor.
500 A*                   *PULRTN  - Pull - Return dropped plts to slot
500 A*                   *PULTRAN - Pull - In transit
500 A*                   *PULUNDO - Pull - Undo
500hA*                   *ADJUST  - Adjust slot/license quantity.
500uA*                              LT210FM not opened.
500lA*                   *INVCNTB - Inventory Count.
500lA*                                Before inventory count file updated.
500qA*                   *NQDROP  - Drop pallet to floor w/o questions
500sA*                   *RMVZERO - Remove (Inactivate) record for a
500sA*                              specific slot if all qtys are zero.
500sA*                   *RMVZRTN - Remove (Inactivate) record for a
500sA*                              specific slot if all qtys are zero,
500sA*                              then do a PULRTN.
     *      $pprogram  - Calling program name
     *      $ptype     - PUT - Putaway
     *                   TFR - Transfer
     *                   RPL - Replenishment
     *                   LET - Letdown
     *                   PRP - Priority Replenishment
     *                   SSR - Single Slot Replenishment
500gA*                   BRK - Breakdown replenishment.
500gA*                   FLW - Flowrack replenishment.
     *      $phead     - Main heading
     *      $pwhse     - Warehouse
     *      $pitem     - Item number
     *      $pitemdsc  - Item description heading
     *      $pwhdp     - Department
     *      $pslot     - Slot number
     *      $pslotpos  - Slot pallet positions
     *      $pempl#    - Employee number
     *      $ptran#    - Transaction number
     *      $plic#     - License number
     *      $pnewlic#  - New licence number (partial replenishment).
     *      $pqty1     - Quantity 1
     *      $pqty2     - Quantity 2
     *      $pqty3     - Quantity 3
500rA*      $pnorm1    - Normal quantity 1
500rA*      $pnorm2    - Normal quantity 2
500rA*      $pnorm3    - Normal quantity 3
     *      $ppartial  - Partial quantity flag (1=Yes, 2=No)
     *      $ppulled   - Pallets pulled in *PULL1. Needed for *PULL2.
     *      $ppsplit   - trackpsplit (used for *PUTAWYA)
     *      $pinlic#   - inlic# (used for *PUTAWYA)
     *      $poutlic#  - outlic# (used for *PUTAWYA)
     *      $pnexttask - Task to be performed for *PUTAWYA.
     *
     *    Returned Parameters
     *      $ppulled   - Pallets pulled in *PULL1.
     *      $pinslot   - Item already exists in slot (Y,N)
     *      $psamepos  - Item already exists in same slot position (Y,N)
     *      $pdiffpos  - Item already exists in different slot pos (Y,N)
     *      $ppsplit   - Set to trackpsplit before returning.
     *      $pinlic#   - Set to inlic# before returning.
     *      $poutlic#  - Set to outlic# before returning.
     *      $pnexttask - Task to be performed for *PUTAWYA.
     *      $preturn   - *OK
     *                   *CANCEL - F12 was taken.
     *                   *NOTFND - Item not found for replenishment.
     *      $perrmsg
     *      $pmsgid
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd
     C                   parm                    $pprogram
     C                   parm                    $ptype
     C                   parm                    $phead
     C                   parm                    $pwhse
     C                   parm                    $pitem
     C                   parm                    $pitemdsc
     C                   parm                    $pwhdp
     C                   parm                    $pslot
     C                   parm                    $pslotpos
     C                   parm                    $pempl#
     C                   parm                    $ptran#
     C                   parm                    $plic#
     C                   parm                    $pnewlic#
     C                   parm                    $pqty1
     C                   parm                    $pqty2
     C                   parm                    $pqty3
500rAC                   parm                    $pnorm1
500rAC                   parm                    $pnorm2
500rAC                   parm                    $pnorm3
     C                   parm                    $ppartial
     C                   parm                    $ppulled
     C                   parm                    $pinslot
     C                   parm                    $psamepos
     C                   parm                    $pdiffpos
     C                   parm                    $ppsplit
     C                   parm                    $pinlic#
     C                   parm                    $poutlic#
     C                   parm                    $pnexttask
     C                   parm                    $preturn
     C                   parm                    $perrmsg
     C                   parm                    $pmsgid
