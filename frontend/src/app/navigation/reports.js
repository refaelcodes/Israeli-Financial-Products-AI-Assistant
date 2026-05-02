import { ChartBarIcon } from '@heroicons/react/24/outline'
import { NAV_TYPE_ROOT, NAV_TYPE_ITEM } from 'constants/app.constant'

const ROOT_REPORTS = '/reports'
const path = (root, item) => `${root}${item}`

export const reports = {
    id: 'reports',
    type: NAV_TYPE_ROOT,
    path: ROOT_REPORTS,
    title: 'Reports',
    transKey: 'reports.reports',
    Icon: ChartBarIcon,
    childs: [
        {
            id: 'reports.quarterly',
            path: path(ROOT_REPORTS, '/quarterly'),
            type: NAV_TYPE_ITEM,
            title: 'Quarterly',
            transKey: 'reports.quarterly',
        },
        {
            id: 'reports.yoy',
            path: path(ROOT_REPORTS, '/yoy'),
            type: NAV_TYPE_ITEM,
            title: 'Year over Year',
            transKey: 'reports.yoy',
        },
        {
            id: 'reports.risk',
            path: path(ROOT_REPORTS, '/risk'),
            type: NAV_TYPE_ITEM,
            title: 'Risk',
            transKey: 'reports.risk',
        },
    ],
}
