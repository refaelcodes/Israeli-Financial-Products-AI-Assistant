import { Cog6ToothIcon } from '@heroicons/react/24/outline'
import { NAV_TYPE_ROOT, NAV_TYPE_ITEM } from 'constants/app.constant'

const ROOT_ADMIN = '/admin'
const path = (root, item) => `${root}${item}`

export const admin = {
    id: 'admin',
    type: NAV_TYPE_ROOT,
    path: ROOT_ADMIN,
    title: 'Admin',
    transKey: 'admin.admin',
    Icon: Cog6ToothIcon,
    childs: [
        {
            id: 'admin.institutions',
            path: path(ROOT_ADMIN, '/institutions'),
            type: NAV_TYPE_ITEM,
            title: 'Institutions',
            transKey: 'admin.institutions',
        },
        {
            id: 'admin.mappings',
            path: path(ROOT_ADMIN, '/mappings'),
            type: NAV_TYPE_ITEM,
            title: 'Mappings',
            transKey: 'admin.mappings',
        },
        {
            id: 'admin.users',
            path: path(ROOT_ADMIN, '/users'),
            type: NAV_TYPE_ITEM,
            title: 'Users',
            transKey: 'admin.users',
        },
    ],
}
