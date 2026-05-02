import { NAV_TYPE_ITEM } from "constants/app.constant";
import DashboardsIcon from 'assets/dualicons/dashboards.svg?react'
import { TableCellsIcon, BanknotesIcon, ArrowPathIcon, ShieldExclamationIcon, ChatBubbleLeftRightIcon, ChartBarIcon, Cog6ToothIcon } from '@heroicons/react/24/outline'

export const baseNavigation = [
    {
        id: 'dashboards',
        type: NAV_TYPE_ITEM,
        path: '/dashboards',
        title: 'Dashboards',
        transKey: 'dashboards.dashboards',
        Icon: DashboardsIcon,
    },
    {
        id: 'holdings-explorer',
        type: NAV_TYPE_ITEM,
        path: '/holdings',
        title: 'Holdings Explorer',
        transKey: 'holdings',
        Icon: TableCellsIcon,
    },
    {
        id: 'funds',
        type: NAV_TYPE_ITEM,
        path: '/funds',
        title: 'Funds',
        transKey: 'funds.funds',
        Icon: BanknotesIcon,
    },
    {
        id: 'ingestion',
        type: NAV_TYPE_ITEM,
        path: '/ingestion',
        title: 'Ingestion Runs',
        transKey: 'ingestion',
        Icon: ArrowPathIcon,
    },
    {
        id: 'validation',
        type: NAV_TYPE_ITEM,
        path: '/validation',
        title: 'Validation / Exceptions',
        transKey: 'validation',
        Icon: ShieldExclamationIcon,
    },
    {
        id: 'questions',
        type: NAV_TYPE_ITEM,
        path: '/questions',
        title: 'Client Questions',
        transKey: 'questions',
        Icon: ChatBubbleLeftRightIcon,
    },
    {
        id: 'reports',
        type: NAV_TYPE_ITEM,
        path: '/reports',
        title: 'Reports',
        transKey: 'reports.reports',
        Icon: ChartBarIcon,
    },
    {
        id: 'admin',
        type: NAV_TYPE_ITEM,
        path: '/admin',
        title: 'Admin',
        transKey: 'admin.admin',
        Icon: Cog6ToothIcon,
    },
]
