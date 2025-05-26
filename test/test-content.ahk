
class STO {
    static Get(TestID) {
        switch TestID {
            case 1: return STO.O_Object
        }
    }

    static A_Array := [
        [
            [ 'AAA' Chr('0xFFC') ],
            Map( 'AAM', 'AAM' Chr('0xFFC') ),
            { AAO: 'AAO' Chr('0xFFC') }
        ],
        Map( 'AM1', [ 'AMA' ],
             'AM2', Map('AMM', 'AMM'),
             'AM3', {AMO: 'AMO'}
        ),
        {
            AO1: ['AOA', true],
            AO2: Map(
                'AOM1', 'AOM',
                'AOM2', false
            ),
            AO3: {
                AOO1: 'AOO',
                AOO2: ''
            }
        }
    ]

    static FiftyCharacters := [1,2,3,4,5,60,70,80,90,11,12,13,14,15,16,17,18,19]
    static FiftyOneCharacters := [1,2,3,4,50,60,70,80,90,11,12,13,14,15,16,17,18,19]

    static UnsetArrayItem := [1, , , 1]

    static M_Map := Map(
        'M1', [['MAA'], Map('MAM', 'MAM'), {MAO: 'MAO'}]
      , 'M2', Map('MM1', ['MMA'], 'MM2', Map('MMM', 'MMM'), 'MM3', {MMO: 'MMO'})
      , 'M3', {MO1: ['MOA'], MO2: Map('MOM', 'MOM'), MO3: {MOO: 'MOO'}}
    )

    static O_Object := {
        O1: [['OAA'], Map('OAM', 'OAM'), {OAO: 'OAO'}]
      , O2: Map('OM1', ['OMA'], 'OM2', Map('OMM', 'OMM'), 'OM3', {OMO: 'OMO'})
      , O3: {OO1: ['OOA'], OO2: Map('OOM', 'OOM'), OO3: {OOO: 'OOO'}}
    }

    static A_Condense := [1, 2, 3, 4, 5, 6, 7, 8, [
        9, 10, 11, 12, 13, 14, {
            Prop: 'Value'
            , Prop2: ['Value1', 'Value2', 'Value3', 'Value4']
        }]
    ]

    static M_NumericKeys := Map(1, Map(2, Map(3, Map(4, 'M1234'))))

    static ErrorProp {
        Get {
            return this.__ErrorProp
        }
    }

    static __DynamicPropArrowVal := 1
    static DynamicPropArrow => this.__DynamicPropArrowVal

    static __DynamicPropOnlySet := 1
    static DynamicPropOnlySet {
        Set {
            this.__DynamicPropOnlySet := value
        }
    }

    static __DynamicPropOnlyGet := 1
    static DynamicPropOnlyGet {
        Get {
            return this.__DynamicPropOnlyGet
        }
    }

    static __DynamicPropBoth := 1
    static DynamicPropBoth {
        Get {
            return this.__DynamicPropBoth
        }
        Set {
            this.__DynamicPropBoth := value
        }
    }
}

