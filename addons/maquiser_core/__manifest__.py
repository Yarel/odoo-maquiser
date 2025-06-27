{
    'name': 'Maquiser Core',
    'version': '1.0',
    'category': 'Manufacturing/Textil',  # ¡Clave para agrupación en Apps!
    'summary': 'Sistema ERP textil para Maquiser SRL',
    'description': """
        Módulo central para gestión de producción textil, inventario y ventas.
        Incluye personalización de productos, contactos y flujos de producción.
    """,
    'author': 'Tu Nombre',
    'website': 'https://www.maquiser.com',
    'depends': [
        'base', 
        'product',
        'stock',       # Inventario
        'mrp',         # Manufactura
        'sale',        # Ventas (opcional si necesitas cotizaciones)
        'purchase',    # Compras (opcional)
        'l10n_bo'      # Localización boliviana
    ],
    'data': [
        # SECURITY (debe ir primero)
        'security/security_groups.xml',
        'security/ir.model.access.csv',
        'security/usuarios.xml',
        
        # DATA
        'data/partner_categories.xml',
        'data/partner_data.xml',
        'data/product_data.xml',
        
        # VIEWS
        'views/product_views.xml',
        'views/partner_views.xml',
    ],
    'demo': [
        'demo/product_demo.xml',  # Datos demo opcionales
    ],
    'installable': True,
    'application': True,  # Aparecerá en el menú Apps
    'license': 'LGPL-3',
}