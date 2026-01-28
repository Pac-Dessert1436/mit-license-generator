import tkinter as tk


class AppWindow(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title('MIT License Generator')
        self.geometry('800x600')

        # Configure grid for responsive layout
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(1, weight=1)

        # Create input section
        input_frame = tk.Frame(self, bg='#f5f5f5', bd=0)
        input_frame.grid(row=0, column=0, padx=20, pady=20, sticky='ew')
        input_frame.grid_columnconfigure(0, weight=1)

        # Input labels and fields
        tk.Label(input_frame, text='Copyright (c)').grid(
            row=0, column=0, sticky='e', padx=5, pady=5)

        self.year_var = tk.StringVar()
        year_entry = tk.Entry(
            input_frame, textvariable=self.year_var, width=10, font=('Arial', 14))
        year_entry.grid(row=0, column=1, sticky='w', padx=5, pady=5)

        self.author_var = tk.StringVar()
        author_entry = tk.Entry(
            input_frame, textvariable=self.author_var, width=40, font=('Arial', 14))
        author_entry.grid(row=0, column=2, sticky='ew', padx=5, pady=5)
        input_frame.grid_columnconfigure(2, weight=1)

        # Buttons frame
        button_frame = tk.Frame(input_frame, bg='#f5f5f5')
        button_frame.grid(row=1, column=0, columnspan=3, pady=10)

        self.generate_btn = tk.Button(button_frame, text='Generate License', command=self.generate_license,
                                      bg='#007bff', fg='white', font=('Arial', 12), relief='flat', state='disabled')
        self.generate_btn.pack(side='left', padx=5)

        self.copy_btn = tk.Button(button_frame, text='Copy to Clipboard', command=self.copy_to_clipboard,
                                  bg='#007bff', fg='white', font=('Arial', 12), relief='flat', state='disabled')
        self.copy_btn.pack(side='left', padx=5)

        # Output section
        output_frame = tk.Frame(self)
        output_frame.grid(row=1, column=0, padx=20,
                          pady=(0, 20), sticky='nsew')
        output_frame.grid_columnconfigure(0, weight=1)
        output_frame.grid_rowconfigure(0, weight=1)

        # License output text area
        self.license_text = tk.Text(output_frame, font=('Courier New', 11), wrap='word',
                                    bg='#f8f9fa', borderwidth=1, relief='solid')
        self.license_text.grid(row=0, column=0, sticky='nsew')
        self.license_text.insert(
            '1.0', 'Please enter the year and author above to generate the MIT License text.')
        self.license_text.config(state='disabled')

        # Scrollbar
        scrollbar = tk.Scrollbar(output_frame, command=self.license_text.yview)
        scrollbar.grid(row=0, column=1, sticky='ns')
        self.license_text.config(yscrollcommand=scrollbar.set)

        # Message label
        self.message_var = tk.StringVar()
        self.message_label = tk.Label(
            self, textvariable=self.message_var, font=('Arial', 12))
        self.message_label.grid(row=2, column=0, padx=20,
                                pady=(0, 10), sticky='w')

        # Event bindings
        self.year_var.trace_add('write', self.validate_inputs)
        self.author_var.trace_add('write', self.validate_inputs)

        year_entry.bind('<KeyPress>', self.validate_year_keypress)

        # Keyboard shortcut for generate (Ctrl+Enter)
        self.bind('<Control-Return>', lambda _: self.generate_license()
                  if self.generate_btn['state'] != 'disabled' else None)

    def validate_inputs(self, name, index, mode):
        import re
        
        _ = name, index, mode
        year = self.year_var.get().strip()
        author = self.author_var.get().strip()

        # Basic validation
        is_valid_year = re.match(r'^\d{4}$', year) is not None
        is_valid_author = len(author) > 0

        if is_valid_year and is_valid_author:
            self.generate_btn.config(state='normal')
        else:
            self.generate_btn.config(state='disabled')

    def validate_year_keypress(self, event):
        # Only allow numbers and backspace
        if not (event.char.isdigit() or event.keysym == 'BackSpace'):
            return 'break'

    def generate_license(self):
        year = self.year_var.get().strip()
        author = self.author_var.get().strip()

        license_text = f"MIT License\n\nCopyright (c) {year} {author}\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the \"Software\"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all\ncopies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\nSOFTWARE."

        self.license_text.config(state='normal')
        self.license_text.delete('1.0', tk.END)
        self.license_text.insert('1.0', license_text)
        self.license_text.config(state='disabled')

        self.copy_btn.config(state='normal')
        self.show_message('License generated successfully!', 'success')

    def copy_to_clipboard(self):
        license_content = self.license_text.get('1.0', tk.END).strip()
        if license_content:
            self.clipboard_clear()
            self.clipboard_append(license_content)
            self.update()  # Update the clipboard
            self.show_message('License copied to clipboard!', 'success')
        else:
            self.show_message('No license to copy', 'error')

    def show_message(self, text, message_type):
        if message_type == 'success':
            self.message_label.config(fg='#28a745')
        else:
            self.message_label.config(fg='#dc3545')

        self.message_var.set(text)

        # Clear message after 3 seconds
        self.after(3000, lambda: self.message_var.set(''))


if __name__ == '__main__':
    AppWindow().mainloop()
