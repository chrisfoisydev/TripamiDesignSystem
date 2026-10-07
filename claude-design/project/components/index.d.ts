// Tripami components (window.Tripami). Mirrors the Flutter TP* widgets.
import type { ReactNode } from 'react';

export type IconName = string; // one of Tripami.iconNames (Phosphor, camelCase: 'mapPin', 'calendarBlank', …)
export type MemberColor = 'lagoon' | 'sky' | 'iris' | 'plum' | 'rose' | 'fern' | 'olive' | 'slate';
export interface Member { name: string; color: MemberColor; photo?: string; online?: boolean }

export interface IconProps { name: IconName; size?: number; fill?: boolean; label?: string; color?: string; className?: string }
export interface ButtonProps { variant?: 'primary' | 'secondary' | 'tertiary' | 'destructive'; small?: boolean; expand?: boolean; loading?: boolean; disabled?: boolean; type?: 'button' | 'submit'; onClick?: () => void; children: ReactNode }
export interface GlassIconButtonProps { icon: IconName; label: string; onClick?: () => void }
export interface QuickActionProps { icon: IconName; label: string; onClick?: () => void }
export interface FloatingPillProps { icon?: IconName; onClick?: () => void; children: ReactNode }
export interface FilterChipProps { selected?: boolean; defaultSelected?: boolean; count?: number; dropdown?: boolean; onClick?: () => void; children: ReactNode }
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
export interface ListRowProps { label: string; detail?: string; icon?: IconName; leading?: ReactNode; value?: string; trailing?: ReactNode; onClick?: () => void; chevron?: boolean; divider?: boolean }
export interface StickyActionBarProps { label?: string; value?: string; detail?: string; action: ReactNode }
export interface SheetProps { title: string; onClose?: () => void; footer?: ReactNode; children: ReactNode }
export interface EmptyStateProps { title: string; message: string; action?: ReactNode; illustration?: ReactNode }
export interface ToastProps { actionLabel?: string; onAction?: () => void; children: ReactNode }
export interface TabBarItem { label: string; icon: IconName; activity?: 'new' | 'urgent' }
export interface TabBarProps { items: TabBarItem[]; value?: number }
export interface AvatarProps { member: Member; size?: 24 | 32 | 40 | 56 | 88; presence?: boolean; invited?: boolean; className?: string }
export interface AvatarStackProps { members: Member[]; size?: number; max?: number; onImage?: boolean }
export interface AttributionProps { member: Member; action: string; time?: string }
export interface ActivityDotProps { urgent?: boolean }
export interface Reaction { emoji: string; count: number; mine?: boolean }
export interface ReactionBarProps { reactions: Reaction[]; onReact?: (reaction: Reaction) => void; onAdd?: false | (() => void) }
export interface PollOption { id: string; title: string; detail?: string; image?: string; voters: Member[] }
export interface PollCardProps { eyebrow: string; question: string; options: PollOption[]; myVoteId?: string; waitingOn?: string[]; deadline?: string; decidedId?: string; onVote?: false | (() => void) }
export interface ItineraryItemProps { time: string; title: string; detail?: string; state?: 'planned' | 'now' | 'booked' | 'idea'; addedBy?: Member; addedWhen?: string; reactions?: Reaction[]; footer?: ReactNode; last?: boolean }
export interface BraidGroup { id: string; name: string; color: MemberColor; memberIds: string[] }
export interface BraidEvent { id: string; title: string; participantIds: string[]; start?: string; end?: string; place?: string; loose?: boolean; now?: boolean }
export interface BraidMoment { time: string; events: BraidEvent[] }
export interface BraidDayProps { members: (Member & { id: string })[]; youId: string; moments: BraidMoment[]; groups?: BraidGroup[]; maxVisibleEvents?: number; width?: number }
export interface BraidEventCardProps { label: string; title: string; detail?: string; mine?: boolean; loose?: boolean; now?: boolean; footer?: ReactNode }
export interface BraidMarkerProps { time: string; summary: string }
export interface PopProps { delay?: number; children: ReactNode }
export interface RiseProps { index?: number; children: ReactNode }
export interface BrandDotProps { size?: number; delay?: number }
export interface SuccessCheckProps { size?: number; still?: boolean; haptic?: boolean }
export interface CountUpProps { value: number; from?: number; format?: (value: number) => string; className?: string }
export type HapticKind = 'select' | 'join' | 'reorder' | 'success' | 'warning';
/** Tripami.haptic(kind): plays a haptic where the browser supports vibration. Tripami.hapticsEnabled = false mutes it. */
export type Haptic = (kind: HapticKind) => void;
export interface RoleTagProps { pending?: boolean; children: ReactNode }
export interface GroupRowProps { members: Member[]; title: string; detail?: string; value?: string; onClick?: () => void; chevron?: boolean; divider?: boolean }
export interface ConnectCardProps { icon: IconName; title: string; message: string; kinds?: IconName[]; actionLabel: string; onConnect?: () => void; loading?: boolean }
export interface BackdropProps { kind: 'photo' | 'braid' | 'route'; image?: string; members?: Member[]; height?: number; children?: ReactNode }
export interface PlaceHeaderProps { title: string; image?: string; imageLabel: string; eyebrow?: string; subtitle?: string; credit?: string; leading?: ReactNode; trailing?: ReactNode | ReactNode[]; minHeight?: number; sheetBelow?: boolean }
export interface OverlapSheetProps { children?: ReactNode }
export interface ProgressBarProps { value: number; label: string; color?: string }
/** start, end and now are "HH:MM" on one day. Leave now out to follow the real time. */
export interface NowCardProps { title: string; place?: string; start: string; end: string; companions?: Member[]; now?: string; onClick?: () => void }
export interface LeaveByHintProps { leaveBy: string; travel: string; now?: string; soonWindow?: number }
export interface ExpenseRowProps { icon?: IconName; title: string; paidBy: Member; splitWays: number; amount: string; yourShare: string; youOwe: boolean }
