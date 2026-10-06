// Tripami components (window.Tripami). Mirrors the Flutter TP* widgets.
import type { ReactNode } from 'react';

export type IconName = string; // one of Tripami.iconNames (Phosphor, camelCase: 'mapPin', 'calendarBlank', …)
export type MemberColor = 'clay' | 'marigold' | 'fern' | 'sky' | 'iris' | 'plum' | 'rose' | 'olive';
export interface Member { name: string; color: MemberColor; photo?: string; online?: boolean }

export interface IconProps { name: IconName; size?: number; fill?: boolean; label?: string; color?: string; className?: string }
export interface ButtonProps { variant?: 'primary' | 'secondary' | 'tertiary' | 'destructive'; small?: boolean; expand?: boolean; loading?: boolean; disabled?: boolean; type?: 'button' | 'submit'; onClick?: () => void; children: ReactNode }
export interface GlassIconButtonProps { icon: IconName; label: string; onClick?: () => void }
export interface QuickActionProps { icon: IconName; label: string; onClick?: () => void }
export interface FloatingPillProps { icon?: IconName; onClick?: () => void; children: ReactNode }
export interface FilterChipProps { selected?: boolean; count?: number; dropdown?: boolean; onClick?: () => void; children: ReactNode }
export interface UnderlineTabsProps { labels: string[]; value?: number; onChange?: (index: number) => void }
export interface TextFieldProps { label: string; id?: string; defaultValue?: string; placeholder?: string; help?: string; error?: string; inputMode?: string }
export interface ToggleProps { label: string; defaultChecked?: boolean }
export interface EyebrowProps { children: ReactNode; className?: string }
export interface SectionHeaderProps { title: string; titled?: boolean; subtitle?: string; action?: string; onAction?: () => void }
export interface CardProps { padding?: number | string; className?: string; children: ReactNode }
export interface GlassChipProps { icon?: IconName; children: ReactNode }
export interface TripCoverCardProps { title: string; subtitle: string; image?: string; status?: string; members?: Member[]; aspectRatio?: string }
export interface TripFact { label: string; value?: string; detail?: string; content?: ReactNode }
export interface TripStripProps { facts: TripFact[] }
export interface ListRowProps { label: string; detail?: string; icon?: IconName; leading?: ReactNode; value?: string; onClick?: () => void; chevron?: boolean; divider?: boolean }
export interface StickyActionBarProps { label?: string; value?: string; detail?: string; action: ReactNode }
export interface SheetProps { title: string; onClose?: () => void; footer?: ReactNode; children: ReactNode }
export interface EmptyStateProps { title: string; message: string; action?: ReactNode; illustration?: ReactNode }
export interface ToastProps { actionLabel?: string; onAction?: () => void; children: ReactNode }
export interface TabBarItem { label: string; icon: IconName; activity?: 'new' | 'urgent' }
export interface TabBarProps { items: TabBarItem[]; value?: number }
export interface AvatarProps { member: Member; size?: 24 | 32 | 40 | 56 | 88; presence?: boolean }
export interface AvatarStackProps { members: Member[]; size?: number; max?: number; onImage?: boolean }
export interface AttributionProps { member: Member; action: string; time?: string }
export interface ActivityDotProps { urgent?: boolean }
export interface Reaction { emoji: string; count: number; mine?: boolean }
export interface ReactionBarProps { reactions: Reaction[]; onAdd?: false | (() => void) }
export interface PollOption { id: string; title: string; detail?: string; image?: string; voters: Member[] }
export interface PollCardProps { eyebrow: string; question: string; options: PollOption[]; myVoteId?: string; waitingOn?: string[]; deadline?: string; decidedId?: string; onVote?: false | (() => void) }
export interface ItineraryItemProps { time: string; title: string; detail?: string; state?: 'planned' | 'now' | 'booked' | 'idea'; addedBy?: Member; addedWhen?: string; reactions?: Reaction[]; footer?: ReactNode; last?: boolean }
export interface ExpenseRowProps { icon?: IconName; title: string; paidBy: Member; splitWays: number; amount: string; yourShare: string; youOwe: boolean }
