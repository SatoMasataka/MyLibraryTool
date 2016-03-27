#encoding: UTF-8
require 'java'
require 'nokogiri'
require 'open-uri'
require 'win32ole'
require 'kconv'

import 'javax.swing.JComboBox'
import 'javax.swing.border.LineBorder'
import 'javax.swing.JFrame'
import 'javax.swing.JDialog'
import 'javax.swing.JButton'
import 'javax.swing.JTextField'
import 'javax.swing.JTextArea'
import 'javax.swing.JScrollPane'
import 'javax.swing.ImageIcon'
import 'javax.swing.JOptionPane'
import 'javax.swing.JLabel'
import 'javax.swing.JPanel'
import 'java.awt.BorderLayout'
import 'java.awt.Color'
import 'java.awt.Dimension'



#-------Util-------#

CREATE_NEW_CATE = "[新規カテゴリ作成]"

#-------イベント-------#
#メイン：登録ボタン押下
class BtnRegi_Click
	include java.awt.event.ActionListener
	
	#コンストラクタ
	def initialize(txt)
		@txt=txt
	end
	
	#イベントハンドラ
	def actionPerformed(evt)
		
		#タイトル加工後、登録対象文字列をグローバル変数に取っておく
		$registerTxt = @txt.getText.sub("\n","\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
		
		#カテゴリ1パネルへ遷移
		CatePanel.new('1',nil)
		$mainFrame.visible=false
		
	end
end


#メイン：辞書オープンボタンクリック
class BtnOpnDic_Click
	include java.awt.event.ActionListener
	
	#イベントハンドラ
	def actionPerformed(evt)
		#スフィンクスコンパイル
		%x[make html]
		
		#ＩＥで辞書開く
		ie = WIN32OLE.new("InternetExplorer.Application")
		ie.visible = true 
		ie.Navigate('C:\Users\Masataka\MyLibraryTool\MyLibrary\_build\html\index.html')  # Todo 絶対パス取得

	end
end

#カテ入力:次へボタンクリック
class BtnNext_Click
	include java.awt.event.ActionListener
	
	def initialize(cSeq,cmbCate,txtNewCate)
		@cateSeq = cSeq
		@cmbCate= cmbCate
		@txtNewCate=txtNewCate
	end
	
	#イベントハンドラ
	def actionPerformed(evt)
		
		case @cateSeq
			when '1'															#カテ1⇒カテ2
				@@newCate1 =@txtNewCate.getText().to_s
				$cateFrame1.visible=false
				@@selectedCateSeq1 = $arrCateSeq1[@cmbCate.getSelectedIndex()]
				CatePanel.new('2',@@selectedCateSeq1)
			when '2'															#カテ2⇒メイン
				@@newCate2 =@txtNewCate.getText().to_s
				$cateFrame2.visible=false
				$mainFrame.visible=true
				@@selectedCateSeq2 = $arrCateSeq2[@cmbCate.getSelectedIndex()]
		
			
				#新カテゴリーの追加
				if (@@selectedCateSeq2  =="xxxxx")
					
					#大カテゴリーも追加の場合
					if( @@selectedCateSeq1 =="xxxxx")
						@@selectedCateSeq1 = format("%05d", $arrCateSeq1.length)
						
						#index.rstの更新
						insertCate="\n.. " + @@selectedCateSeq1 + "\n" + @@newCate1 + "\n========================================\n\n.. toctree::\n   :maxdepth: 2\n\n   .. "+@@selectedCateSeq1+"InsertPoint\n\n\n.. NextCateInsertPoint"
						insertIntoIndexRst(".. NextCateInsertPoint", insertCate)
						
						##大カテcsvへの追記
						#追記かつ読み書き両用で開く
						File.open("./Cate/Cate.csv" , File::APPEND | File::RDWR ) do |f|
							f.write("," + @@selectedCateSeq1 + @@newCate1) 
						end
						
						#小カテｃｓｖ作成
						File.open("./Cate/Cate" + @@selectedCateSeq1 +".csv" , "w" )
					end
					
					#小カテゴリ追加の場合
					@@selectedCateSeq2 = format("%05d", $arrCateSeq2.length)
					
					#ファイル作成
					newFlNm = "./Cate_" + @@selectedCateSeq1 + "_" + @@selectedCateSeq2 + ".rst"
					File.open(newFlNm , "w" ) do |f|
						f.write(".. " +@@selectedCateSeq1+"_"+@@selectedCateSeq2+"\n"+@@newCate2+"\n----------------------------") 
					end
					
					#index.rstの更新
					cateFlg = ".. "+@@selectedCateSeq1+"InsertPoint"
					insTxt= newFlNm+"\n   "+cateFlg
					insertIntoIndexRst(cateFlg,insTxt)
					
					##小カテcsvへの追記
					#追記かつ読み書き両用で開く
					File.open("./Cate/Cate" + @@selectedCateSeq1 +".csv" , File::APPEND | File::RDWR ) do |f|
						f.write("," + @@selectedCateSeq2 + @@newCate2) 
					end
				end
				
				
				flname = "./Cate_" + @@selectedCateSeq1 + "_" + @@selectedCateSeq2 + ".rst"
				
				#既存ファイルへの登録処理
				#追記かつ読み書き両用で開く
				File.open(flname , File::APPEND | File::RDWR ) do |f|
					f.write("\n\n" + $registerTxt) 
				end
		end
	end
	
	
	#index.rstへ挿入追記
	def insertIntoIndexRst(insertFlg,insertTxt)
		str = File.open("./index.rst").read
		str = str.encode("Windows-31J", "UTF-8",
           invalid: :replace,
           undef: :replace,
           replace: '.').encode("UTF-8")

		str = str.sub(insertFlg , insertTxt)
		File.open("./index.rst" , "w" ) do |f|
			f.write(str) 
		end
	end
	
end

#カテ入力:キャンセルボタンクリック
class BtnCancel_Click
	include java.awt.event.ActionListener
	
	def actionPerformed(evt)
		$mainFrame.visible=true
		$cateFrame1.visible=false  if !$cateFrame1.nil?
		$cateFrame2.visible=false  if !$cateFrame2.nil?
	end
end


#カテ入力:戻るボタンクリック
class BtnBack_Click
	include java.awt.event.ActionListener
	
	def initialize(cSeq)
		@cateSeq = cSeq
	end

	def actionPerformed(evt)
		case @cateSeq
		when '1'															#カテ1⇒メイン
			$cateFrame1.visible=false
			$mainFrame.visible=true
		when '2'															#カテ2⇒カテ1
			$cateFrame2.visible=false
			$cateFrame1.visible=true
		end
	end
end	

#カテ入力:コンボボックス選択値変更
class CbxCate_Change
	def initialize(cbxCate,txtNewCate)
		@cbxCate = cbxCate
		@txtNewCate = txtNewCate
	end
	
	def actionPerformed(evt)
		#コンボボックス選択値が新規カテゴリ作成であればテキストボックスを活性化
		if(@cbxCate.getSelectedItem.to_s == CREATE_NEW_CATE)
			@txtNewCate.setEnabled(true)
		else
			@txtNewCate.setEnabled(false)
		end
		
	end
	
end

#-------メソッド-------#

#メインフォームの生成
class MainPanel

	#コンストラクタ
	def initialize
		
		#コントロール定義
		btnRegi = JButton.new("登録")
		btnOpnDic = JButton.new("辞書オープン")
		txtArea = JTextArea.new(10,100)
		
		
		#イベント設定
		btnRegi.add_action_listener(BtnRegi_Click.new(txtArea))   #Textボックスの値だけ渡そうとしてもうまくいかない
		btnOpnDic.add_action_listener(BtnOpnDic_Click.new())
		
			
		#パネルへコントロールをAdd
		##上パネル
		panel1 = JPanel.new
		panel1.add(btnRegi)
		panel1.add(btnOpnDic)
		
		##テキストエリアパネル
		scrollpane = JScrollPane.new(txtArea);
		
		#フレーム設定
		frame = JFrame.new("MyLiblarySystem")
		frame.getContentPane.add(panel1,BorderLayout::NORTH)
		frame.getContentPane.add(scrollpane,BorderLayout::CENTER)
		frame.setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
		frame.pack
		frame.visible = true
		frame.setBounds(0,0,1500,500)
		
		$mainFrame=frame
	end
end


#カテゴリフォームの生成
class CatePanel
	
	#コンストラクタ
	def initialize(cSeq,selectedCateIdx)
		@cateSeq = cSeq
		case @cateSeq
			when '1'
				@cateNm="カテゴリ1"
				$arrCateSeq1 = Array.new()
				@modelForCate=getCategoryData("./Cate/Cate.csv", $arrCateSeq1)
			when '2'
				@cateNm="カテゴリ2"
				if (selectedCateIdx != "xxxxx")
					$arrCateSeq2 = Array.new()
					@modelForCate = getCategoryData("./Cate/Cate_" + selectedCateIdx + ".csv", $arrCateSeq2)
				else
					$arrCateSeq2 = ["xxxxx"]
					@modelForCate = [CREATE_NEW_CATE]
				end
		end
	
		#フォーム表示
		makePanel
	end
	
	
	#フォーム生成
	def makePanel
		cbxCate = JComboBox.new(@modelForCate.to_java)			#javaのオブジェクト型へ変換
		txtNCate = JTextField.new(20)
		txtNCate.setDisabledTextColor(Color::WHITE)
		lblCate = JLabel.new(@cateNm)
		btnBack = JButton.new("一つ戻る")
		btnCancel = JButton.new("キャンセル")
		btnNext = JButton.new(@cateSeq != '2' ? "次へ":"登録")

		#イベントバインド
		btnCancel.add_action_listener(BtnCancel_Click.new)
		btnNext.add_action_listener(BtnNext_Click.new(@cateSeq,cbxCate,txtNCate))
		btnBack.add_action_listener(BtnBack_Click.new(@cateSeq))
		cbxCate.add_action_listener(CbxCate_Change.new(cbxCate,txtNCate))

		#パネルへコントロールをAdd
		pnl = JPanel.new
		pnl.add(lblCate)
		pnl.add(cbxCate)
		pnl.add(txtNCate) 
		pnl.add(btnBack)
		pnl.add(btnNext)
		pnl.add(btnCancel)
		
		dia = JDialog.new()
		dia.setTitle("カテゴリ選択")
		dia.getContentPane.add(pnl)
		dia.pack
		dia.visible = true
		dia.setBounds(0,0,500,300)
		
		#ダイアログをグローバル変数に取っておく
		case @cateSeq
			when '1'
				$cateFrame1=dia
			when '2'
				$cateFrame2=dia
		end
		
		#テキストボックス非活性化
		if(cbxCate.getSelectedItem.to_s == CREATE_NEW_CATE)
			txtNCate.setEnabled(true)
		else
			txtNCate.setEnabled(false)
		end
	end
	
	
	#csvを分析
	def getCategoryData(fPath,arrCateSeq)
		enc="UTF-8"
		f = File.open(fPath,"r:#{enc}").read
		dataArr = f.split(',')
		
		#arrCateSeq=Array.new()
		arrCateNm=Array.new()
		
		dataArr.each do |data|
			arrCateSeq[arrCateSeq.length] = data[0..4] 									#カテゴリシーケンス
			arrCateNm[arrCateNm.length] = data[5..-1]										#カテゴリ名
		end
		
		arrCateSeq[arrCateSeq.length] = "xxxxx"
		arrCateNm[arrCateNm.length] = CREATE_NEW_CATE
		
		return arrCateNm
	end
end


#-------メイン-------#
#p File.expand_path(__FILE__)
MainPanel.new
