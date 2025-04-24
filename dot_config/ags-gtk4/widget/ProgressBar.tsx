import { Gtk, type ConstructProps } from 'astal/gtk4'
import { GObject } from 'astal'

export default class ProgressBar extends Gtk.ProgressBar {
  static { GObject.registerClass(this) }

  constructor(props: ConstructProps<ProgressBar, Gtk.ProgressBar.ConstructorProps>) {
    super(props as any)
  }
}