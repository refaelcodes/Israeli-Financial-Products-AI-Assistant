import { BanknotesIcon } from '@heroicons/react/24/outline'
import { NAV_TYPE_ROOT, NAV_TYPE_ITEM } from 'constants/app.constant'

const ROOT_FUNDS = '/funds'
const path = (root, item) => `${root}${item}`

export const funds = {
    id: 'funds',
    type: NAV_TYPE_ROOT,
    path: ROOT_FUNDS,
    title: 'Funds',
    transKey: 'funds.funds',
    Icon: BanknotesIcon,
    childs: [
        {
            id: 'funds.pensia',
            path: path(ROOT_FUNDS, '/pensia'),
            type: NAV_TYPE_ITEM,
            title: 'Pensia',
            transKey: 'funds.pensia',
        },
        {
            id: 'funds.gemel',
            path: path(ROOT_FUNDS, '/gemel'),
            type: NAV_TYPE_ITEM,
            title: 'Gemel',
            transKey: 'funds.gemel',
        },
    ],
}
