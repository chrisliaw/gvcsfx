# Copyright (C) 2020  Chris Liaw <chrisliaw@antrapol.com>
# Author: Chris Liaw <chrisliaw@antrapol.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


require 'date'

module GvcsFx
  module TabLogs

    class VcsLog
      include Antrapol::ToolRack::ExceptionUtils
      include javafx.beans.value.ObservableValue

      attr_accessor :key, :date, :author_name, :author_email, :subject, :body, :notes
      def reformatted_date
        if not_empty?(@date)
          dt = DateTime.strptime(@date,"%a %b %e %H:%M:%S %Y %z")
          dt.strftime("%H:%M, %d.%b.%Y (%a)")
        else
          @date
        end
      end

      def addListener(list)
      end

      def removeListener(list)
      end

      def value
        self
      end

    end # VcsLog

    class LogCellFactory < javafx.scene.control.TableCell
      attr_accessor :tableColumn
      def updateItem(itm,e)
        super
        if not itm.nil?
          d = []
          d << "Commit : #{itm.key}\n"
          d << "#{itm.subject}"
          lbl = javafx.scene.text.Text.new(d.join("\n"))
          lbl.wrappingWidthProperty.bind(@tableColumn.widthProperty)
          setGraphic(lbl)
        else
          setGraphic(nil)
        end
      end
    end

    def init_tab_logs

      @tblLogs.placeholder = javafx.scene.control.Label.new("Log has no entries yet.")

      @tblLogs.columns.clear
      @tblLogs.column_resize_policy = javafx.scene.control.TableView::CONSTRAINED_RESIZE_POLICY

      cols = []
      colDate = TableColumn.new("Date")
      colDate.cell_value_factory = Proc.new do |p|
        SimpleStringProperty.new(p.value.reformatted_date)
      end
      colDate.sortable = false
      cols << colDate
      
      colSubj = TableColumn.new("Subject")
      colSubj.cell_value_factory = Proc.new do |p|
        p.value
      end
      colSubj.cell_factory = Proc.new do |pa|
        cell = LogCellFactory.new
        cell.tableColumn = pa
        cell
      end
      colSubj.sortable = false
      cols << colSubj

      colAuthor = TableColumn.new("Committer")
      colAuthor.cell_value_factory = Proc.new do |p|
        SimpleStringProperty.new(p.value.author_name)
      end
      colAuthor.sortable = false
      cols << colAuthor


      @tblLogs.columns.add_all(cols)

      # set column width
      #colState.pref_width_property.bind(@tblChanges.width_property.multiply(0.1))
      #colState.max_width_property.bind(colState.pref_width_property)
      #colState.resizable = false
      colDate.pref_width = 220.0
      colDate.max_width = colDate.pref_width
      colDate.min_width = colDate.pref_width

      colAuthor.pref_width = 180.0
      colAuthor.max_width = colAuthor.pref_width
      colAuthor.min_width = colAuthor.pref_width

      @tblLogs.selection_model.selection_mode = javafx.scene.control.SelectionMode::SINGLE

      @tblLogs.add_event_handler(javafx.scene.input.MouseEvent::MOUSE_CLICKED, Proc.new do |evt|
        if evt.button == javafx.scene.input.MouseButton::SECONDARY
          # right click on item
          logs_ctxmenu.show(@tblLogs, evt.screen_x, evt.screen_y)
        elsif evt.button == javafx.scene.input.MouseButton::PRIMARY and evt.click_count == 2
         
          sel = @tblLogs.selection_model.selected_item

          if not sel.nil?

            st, res = @selWs.show_log(sel.key)

            if st
              show_content_win("Log Detail", "Show Log Detail - #{sel.key}", res)
            else
              set_err_gmsg("Log detail for key '#{s.key}' failed. [#{res}]")
            end

          end

        end

      end)

      @txtLogLimit.text = "50"
      
    end # init_tab_logs

    def refresh_tab_logs
      limit = @txtLogLimit.text
      st, res = @selWs.logs({ limit: limit })
      if st
        
        entries = []
        res.each_line do |l|
          
          #puts l

          ll = l.split("|")

          log = VcsLog.new
          log.key = ll[0].strip
          log.date = ll[1].strip
          author = ll[2].nil? ? "" : ll[2].strip
          if not_empty?(author)
            aa = author.split(",")
            log.author_name = aa[0].nil? ? "" : aa[0].strip
            log.author_email = aa[1].nil? ? "" : aa[1].strip
          end
          log.subject = ll[3].strip
          log.body = ll[4].nil? ? "" : ll[4].strip
          log.notes = ll[5].nil? ? "" : ll[5].strip
          
          entries << log
        end

        @tblLogs.items.clear
        @tblLogs.items.add_all(entries)

      else
        @tblLogs.items.clear
      end
    end # refresh_tab_logs

    private
    def logs_ctxmenu

      @selLog = @tblLogs.selection_model.selected_items

      @logsCtxMenu = javafx.scene.control.ContextMenu.new

      if @selLog.length > 0

        # 
        # Copy subject menu item
        #
        ccmMnuItm = javafx.scene.control.MenuItem.new("Copy Commit Message")
        ccmMnuItm.on_action do |evt|

          s = @selLog.first
          cc = javafx.scene.input.ClipboardContent.new
          cc.putString(s.subject) 
          javafx.scene.input.Clipboard.getSystemClipboard.setContent(cc)

          set_info_gmsg("Commit message copied to system clipboard. Use Paste operation to paste it into destination.")

        end
        @logsCtxMenu.items.add(ccmMnuItm)
        # 
        # end diff menu item
        #

      end

      @logsCtxMenu

    end

  end
end
