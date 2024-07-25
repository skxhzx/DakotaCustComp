
     *----------------------------------------------------------------
     * Begin C#TRACKVAR  -  Tracking variables
600 A*  02/20/09  DAS  6.00  P#00045
     *    - Created
700aA*  06/27/16  LMC  7.00a
     *    - Revised for new UCI Tracking level 'U'
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Tracking options
     *
     * Tracking levels for field trackitem:
     *
     *
     *
     *
     *----------------------------------------------------------------

     *  tHigh  -  User may be asked to apply new license plate
     *            to a split quantity.
     *            Putaway always creates new slot.
     *            Only 1 license for item allowed in a slot.
     *            Applying new license plate is manditory.
     *            User may be asked to confirm license plate
     *            being used for task.

     D  tHigh          c                   'H'

     *  tMedium  -  User may be asked to apply new license plate
     *              to a split quantity.
     *              Putaway always creates new slot.
     *              Applying new license plate is optional.

     D  tMedium        c                   'M'

     *  tLow  -  User is not asked for any extra info.
     *           All tracking is done in the background.

     D  tLow           c                   'L'

700aA*  tUCI   -  From a license Standpoint works just like tHigh
700aA*            User may be asked to apply new license plate
700aA*            to a split quantity.
700aA*            Putaway always creates new slot.
700aA*            Only 1 license for item allowed in a slot.
700aA*            Applying new license plate is manditory.
700aA*            User may be asked to confirm license plate
700aA*            being used for task.
700aA*         -  Additional tracking requires UCI scanning
700aA
700aAD  tUCI           c                   'U'
700aA
     *** End C#TRACKVAR ***
