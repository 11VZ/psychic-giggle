import tkinter as tk

def main():
    root = tk.Tk()
    root.title("Simple GUI")
    root.geometry("200x100")
    
    label = tk.Label(root, text="Hi", font=("Arial", 20))
    label.pack(expand=True)
    
    root.mainloop()

if __name__ == "__main__":
    main()
