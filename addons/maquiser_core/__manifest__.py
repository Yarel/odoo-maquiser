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
        'sale',        # Ventas 
        'sale_management',
        'purchase',    # Compras
        'l10n_bo'      # Localización boliviana
    ],
    'data': [
        # SECURITY
        'security/security_groups.xml',
        'security/ir.model.access.csv',
        'security/usuarios.xml',
        
        # DATA
        'data/partner_categories.xml',
        'data/partner_data.xml',
        'data/product_data.xml',
        'data/uniformology_data.xml',
        'data/sales_data.xml',
        'data/purchase_data.xml',
        
        # VIEWS
        'views/product_views.xml',
        'views/partner_views.xml',
        'views/uniformology_views.xml',

    ],
    'demo': [
        'demo/product_demo.xml',  # Datos demo opcionales
    ],
    'installable': True,
    'application': True, 
    'license': 'LGPL-3',
}