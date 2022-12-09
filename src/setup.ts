import moment from 'moment'
import momentDurationFormatSetup from 'moment-duration-format'
// this works fine and matches the docs. the types are wrong?
momentDurationFormatSetup(moment as any)
if ('moment' in window) {
    momentDurationFormatSetup(window.moment as any)
}