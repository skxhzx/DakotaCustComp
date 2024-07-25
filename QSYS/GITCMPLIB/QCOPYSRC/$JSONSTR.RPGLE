     *----------------------------------------------------------------
     * Begin $JSONSTR   Create JSON string routines
     *                    P.JSONSTR is needed for this
     *
     *   04/13/21  DAS  7.50
     *     - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * JsonGetFields    Get fields for a JSON node
     *----------------------------------------------------------------

     p JsonGetFields   b
     d JsonGetFields   pi
     d  node                               like(yajl_val) const

     * Local Variables

     d i               s             10i 0
     d key             s             50a   varying
     d val             s                   like(yajl_val)

      /free

        i = 0;

        // Loop through key/value pairs

        dow YAJL_OBJECT_LOOP( node: i: key: val );

          // Ignore keys where value is another object

          if YAJL_IS_OBJECT(val);
            iter;
          endif;

          // Extract field value and put into a program field

          SetPgmField(key: val);

        enddo;


      /end-free
     p                 e

     *----------------------------------------------------------------
     * JsonGetValue     Get value for JSON pair
     *----------------------------------------------------------------

     p JsonGetValue    b
     d JsonGetValue    pi         65535A   varying
     d  node                               like(yajl_val) const
     d  key                          50A   varying const

     * Local Variables

     d valueNode       s                   like(yajl_val)
     d value           s          65535    varying

      /free

        monitor;
          valueNode = yajl_object_find(node: key);
          if YAJL_IS_NULL(valueNode);
            value = '';
          else;
            value = yajl_get_string(valueNode);
          endif;
        on-error;
          value = '';
        endmon;

        return value;

      /end-free
     p                 e

     *** End $JSONSTR ***

